/// {@template api_repository}
/// A fake API repository
/// {@endtemplate}
class ApiRepository {
  /// {@macro api_repository}
  const ApiRepository();

  /// Fetch Todos

  List<String> fetchTodos() => [
    'make homework',
    'Go to shop',
    'Build a Social media app',
    'Fix some bugs',
  ];
}
