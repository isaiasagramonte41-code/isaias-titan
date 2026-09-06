// Archivo: lib/app_config.dart
class AppConfig {
  // Lee la API Key que le pases al compilar la app
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'CLAVE_POR_DEFECTO_SI_NO_EXISTE',
  );
}