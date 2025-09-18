import 'package:env/env.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:shared/shared.dart' as shared;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Postgres Response codes that we cannot recover from by retrying.
final List<RegExp> fatalResponseCodes = [
  RegExp(r'^22...$'), // Data Exception
  RegExp(r'^23...$'), // Integrity Constraint Violation
  RegExp(r'^42501$'), // Insufficient Privilege
];

/// Use Supabase for authentication and data upload.
class SupabaseConnector extends PowerSyncBackendConnector {
  // ignore: public_member_api_docs
  SupabaseConnector(this.db, {required this.isDev});

  // ignore: public_member_api_docs
  final PowerSyncDatabase db;
  // ignore: public_member_api_docs
  final bool isDev;

  Future<void>? _refreshFuture;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    await _refreshFuture;

    final session = Supabase.instance.client.auth.currentSession;
    shared.logD('Session: ${session?.user.toJson()}');
    if (session == null) return null;

    final token = session.accessToken;
    final userId = session.user.id;
    final expiresAt = session.expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);

    return PowerSyncCredentials(
      endpoint: EnvProd.powersyncUrl,
      token: token,
      userId: userId,
      expiresAt: expiresAt,
    );
  }

  @override
  void invalidateCredentials() {
    _refreshFuture = Supabase.instance.client.auth
        .refreshSession()
        .timeout(5.seconds)
        .then((response) => null, onError: (error) => null);
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    final rest = Supabase.instance.client.rest;
    CrudEntry? lastOp;
    try {
      for (final op in transaction.crud) {
        lastOp = op;
        final table = rest.from(op.table);

        if (op.op == UpdateType.put) {
          final data = Map<String, dynamic>.of(op.opData!);
          data['id'] = op.id;
          await table.upsert(data);
        } else if (op.op == UpdateType.patch) {
          await table.update(op.opData!).eq('id', op.id);
        } else if (op.op == UpdateType.delete) {
          await table.delete().eq('id', op.id);
        }
      }
      await transaction.complete();
    } on PostgrestException catch (e) {
      if (e.code != null &&
          fatalResponseCodes.any((re) => re.hasMatch(e.code!))) {
        shared.logE('Data upload error - discarding $lastOp', error: e);
        await transaction.complete();
      } else {
        rethrow;
      }
    }
  }
}

/// A package that manages connection to the PowerSync cloud service and DB.
class PowerSyncRepository {
  // ignore: public_member_api_docs
  PowerSyncRepository({required this.isDev});

  // ignore: public_member_api_docs
  final bool isDev;

  bool _isInitialized = false;
  late final PowerSyncDatabase _db;
  // ignore: public_member_api_docs
  late final supabase = Supabase.instance.client;

  // ignore: public_member_api_docs
  Future<void> initialize({bool offlineMode = false}) async {
    if (!_isInitialized) {
      await _openDatabase();
      _isInitialized = true;
    }
  }

  // ignore: public_member_api_docs
  PowerSyncDatabase db() {
    if (!_isInitialized) {
      throw Exception(
        'PowerSyncDatabase not initialized. Call initialize() first.',
      );
    }
    return _db;
  }

  // ignore: public_member_api_docs
  bool isLoggedIn() {
    return supabase.auth.currentSession?.accessToken != null;
  }

  // ignore: public_member_api_docs
  Future<String> getDatabasePath() async {
    final dir = await getApplicationSupportDirectory();
    return join(dir.path, 'spaxey-first.db');
  }

  Future<void> _loadSupabase() async {
    await Supabase.initialize(
      url: isDev ? EnvDev.supabaseUrl : EnvProd.supabaseUrl,
      anonKey: isDev ? EnvDev.supabaseAnonKey : EnvProd.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  }

  Future<void> _openDatabase() async {
    _db = PowerSyncDatabase(
      schema: shared.schema,
      path: await getDatabasePath(),
    );
    await _db.initialize();

    await _loadSupabase();

    SupabaseConnector? currentConnector = SupabaseConnector(_db, isDev: isDev);

    if (isLoggedIn()) {
      currentConnector = SupabaseConnector(_db, isDev: isDev);
      await _db.connect(connector: currentConnector);
    }

    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.passwordRecovery) {
        shared.logD('Connect to PowerSync');
        currentConnector = SupabaseConnector(_db, isDev: isDev);
        await _db.connect(connector: currentConnector!);
      } else if (event == AuthChangeEvent.signedOut) {
        currentConnector = null;
        await _db.disconnect();
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        await currentConnector?.prefetchCredentials();
      }
    });
  }

  // ignore: public_member_api_docs
  Stream<AuthState> authStateChanges() =>
      supabase.auth.onAuthStateChange.asBroadcastStream();

  // ignore: public_member_api_docs
  Future<void> updateUser({
    String? email,
    String? phone,
    String? password,
    String? nonce,
    Object? data,
  }) =>
      supabase.auth.updateUser(
        UserAttributes(
          email: email,
          phone: phone,
          password: password,
          nonce: nonce,
          data: data,
        ),
      );

  // ignore: public_member_api_docs
  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) =>
      supabase.auth.resetPasswordForEmail(email, redirectTo: redirectTo);

  // ignore: public_member_api_docs
  Future<void> verifyOTP({
    required String token,
    required String email,
  }) =>
      supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
}
