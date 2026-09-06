import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Corregido: Apunta directamente a la ruta /chat de tu Flask en Render
  final String _backendUrl = 'https://isaias-titan.onrender.com/chat';

  Future<Map<String, dynamic>> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "mensaje": prompt,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return {
          "exito": data["exito"] ?? true,
          "es_video": data["es_video"] ?? false,
          "video_url": data["video_url"] ?? "",
          "respuesta": data["respuesta"] ?? "⚠️ Respuesta vacía recibida de TITÁN.",
        };
      } else {
        print("--- ERROR DEL SERVIDOR ---");
        print("Código: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        return {
          "exito": false,
          "es_video": false,
          "video_url": "",
          "respuesta": "⚠️ Error del servidor: Código ${response.statusCode}",
        };
      }
    } catch (e) {
      print("Error de conexión: $e");
      return {
        "exito": false,
        "es_video": false,
        "video_url": "",
        "respuesta": "⚠️ Error de conexión: $e",
      };
    }
  }
}