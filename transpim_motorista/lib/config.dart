/// Configuração do app.
///
/// Por padrão o app fala com a API REAL. Para usar dados simulados (sem API):
///   flutter run --dart-define=USE_MOCK=true
///
/// Exemplos (a API local sobe em http://0.0.0.0:5178):
///   Emulador Android:  flutter run --dart-define=API_URL=http://10.0.2.2:5178
///   Celular na rede:   flutter run --dart-define=API_URL=http://192.168.1.15:5178
///   Produção (APK):    flutter build apk --release --dart-define=API_URL=https://SEU-APP.onrender.com
class AppConfig {
  static const bool useMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);
  static const String baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5178');
}
