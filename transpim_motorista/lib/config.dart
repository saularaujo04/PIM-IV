/// Configuração do app.
///
/// Rodar com dados simulados (padrão):
///   flutter run
/// Rodar contra a API real (emulador Android acessa o PC em 10.0.2.2):
///   flutter run --dart-define=USE_MOCK=false --dart-define=API_URL=http://10.0.2.2:5000
class AppConfig {
  static const bool useMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: true);
  static const String baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5000');
}
