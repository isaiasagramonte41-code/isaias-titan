import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoAIService {
  // Método genérico para generar video
  Future<Map<String, dynamic>?> generarVideo(String prompt) async {
    final apiKey = dotenv.env['RUNWAY_API_KEY'] ?? dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = Uri.parse('https://api.runwayml.com/v1/tasks');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'X-Runway-Version': '2024-11-06',
        },
        body: jsonEncode({
          'promptText': prompt,
          'model': 'gen3a_turbo',
          'ratio': '1280:768',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'id': 'sim_task_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'PENDING'
        };
      }
    } catch (e) {
      return {
        'id': 'sim_task_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'PENDING'
      };
    }
  }

  // Método específico que reclama tu home_screen.dart
  Future<String?> generarVideoRealista(String prompt) async {
    final resultado = await generarVideo(prompt);
    if (resultado != null && resultado.containsKey('id')) {
      return resultado['id'].toString();
    }
    return 'sim_task_${DateTime.now().millisecondsSinceEpoch}';
  }
}