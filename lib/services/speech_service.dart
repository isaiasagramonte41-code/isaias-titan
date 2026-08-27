class SpeechService {
  bool _isListening = false;

  bool get isListening => _isListening;

  void startListening() {
    _isListening = true;
  }

  void stopListening() {
    _isListening = false;
  }

  Future<void> speak(String text) async {
    // Aquí conectaremos Text-to-Speech más adelante.
  }
}