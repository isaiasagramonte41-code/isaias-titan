class InternetService {
  bool _enabled = false;

  bool get isEnabled => _enabled;

  void enable() {
    _enabled = true;
  }

  void disable() {
    _enabled = false;
  }

  Future<String> search(String query) async {
    if (!_enabled) {
      return "La investigación por Internet está desactivada.";
    }

    // Más adelante aquí conectaremos la búsqueda real.
    return "Investigando: $query";
  }
}