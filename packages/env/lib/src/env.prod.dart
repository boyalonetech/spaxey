// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.prod.g.dart';

@Envied(path: '.env.dev', obfuscate: true)
abstract class EnvProd {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static String supabaseUrl = _EnvProd.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static String supabaseAnonKey = _EnvProd.supabaseAnonKey;

  @EnviedField(varName: 'POWERSYNC_URL', obfuscate: true)
  static String powersyncUrl = _EnvProd.powersyncUrl;
}
