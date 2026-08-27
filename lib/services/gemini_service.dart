import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Clave limpia y sin secretos reales (GitHub la aceptará sin problemas)
  final String _apiKey = "pon tu api key aqui";

  Future<String> generateResponse(String prompt) async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey",
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          // Instrucción de sistema con regla estricta de brevedad
          "system_instruction": {
            "parts": [
              {
                "text":
                    "Te llamas TITÁN. Tu creador es Isaías Patricio Agramonte. REGLA ESTRICTA: Cuando te saluden con un 'hola' o similar, responde de forma ultra corta (máximo una línea, ej: '¡Hola! ¿En qué te ayudo?'). No des discursos largos en saludos simples. Si te preguntan quién te creó, di que fue Isaías Patricio Agramonte de forma directa. Jamás menciones a Google."
              }
            ]
          },
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidate = data["candidates"];
        if (candidate != null && candidate.isNotEmpty) {
          final content = candidate[0]["content"];
          if (content != null && content["parts"] != null) {
            return content["parts"][0]["text"];
          }
        }
        return "⚠️ Respuesta vacía recibida de TITÁN.";
      } else {
        print("--- ERROR DE API ---");
        print("Código: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        return "⚠️ Error de API: Código ${response.statusCode}";
      }
    } catch (e) {
      print("Error de conexión: $e");
      return "⚠️ Error de conexión: $e";
    }
  }
}