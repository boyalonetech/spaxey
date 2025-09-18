import 'package:api_repository/api_repository.dart';
import 'package:spaxey/app/view/app.dart';
import 'package:spaxey/bootstrap.dart';

void main() {
  const apiRepository = ApiRepository();
  bootstrap(
    (powersyncRepository) => App(
      apiRepository: apiRepository,
      powersyncRepository: powersyncRepository,
    ),
    isDev: false, // or false depending on environment
  );
}
