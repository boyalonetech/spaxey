import 'package:api_repository/api_repository.dart';
import 'package:spaxey/app/view/app.dart';
import 'package:spaxey/bootstrap.dart';
import 'package:spaxey/firebase_options_dev.dart';

void main() {
  const apiRepository = ApiRepository();
  bootstrap(
    (powersyncRepository) => App(
      apiRepository: apiRepository,
      powersyncRepository: powersyncRepository,
    ),
    options: DefaultFirebaseOptions.currentPlatform,
    isDev: true, // or false depending on environment
  );
}
