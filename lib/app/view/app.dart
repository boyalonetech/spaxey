import 'package:api_repository/api_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:powersync_repository/src/powersync_repository.dart';
import 'package:spaxey/app/view/app_view.dart';

class App extends StatelessWidget {
  const App({
    required this.apiRepository,
    required this.powersyncRepository,
    super.key,
  });

  final ApiRepository apiRepository;
  final PowerSyncRepository powersyncRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiRepository),
        RepositoryProvider.value(value: powersyncRepository),
      ],
      child: const AppView(),
    );
  }
}
