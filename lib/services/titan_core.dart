import 'gemini_service.dart';
import 'memory_service.dart';
import 'internet_service.dart';
import 'speech_service.dart';

class TitanCore {
  TitanCore._();

  static final TitanCore instance = TitanCore._();

  // Reemplazamos OllamaService por GeminiService
  final GeminiService gemini = GeminiService();
  final MemoryService memory = MemoryService();
  final InternetService internet = InternetService();
  final SpeechService speech = SpeechService();

  Future<String> processMessage(String message) async {
    // Guardamos el mensaje del usuario en la memoria activa
    memory.saveMessage("Usuario: $message");

    // Obtenemos la respuesta directamente de Gemini (con rotación de 4 keys)
    final response = await gemini.generateResponse(message);

    // Guardar la respuesta en el historial
    memory.saveMessage("TITAN: $response");

    return response;
  }

  List<String> getConversationHistory() {
    return memory.getHistory();
  }

  void clearConversation() {
    memory.clear();
  }
}