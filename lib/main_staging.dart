import 'package:api_repository/api_repository.dart';
import 'package:spaxey/app/view/app.dart';
import 'package:spaxey/bootstrap.dart';
import 'package:spaxey/firebase_options_stg.dart';

void main() {
  const apiRepository = ApiRepository();
  bootstrap(
    (powersyncRepository) => App(
      apiRepository: apiRepository,
      powersyncRepository: powersyncRepository,
    ),
    options: DefaultFirebaseOptions.currentPlatform,

    isDev: false, // or false depending on environment
  );
}
