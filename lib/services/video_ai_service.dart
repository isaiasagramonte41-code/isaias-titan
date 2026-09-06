import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoAIService {
  // Apunta directamente a tu backend en Flask (Render)
  final String _backendUrl = 'https://isaias-titan.onrender.com/v1/chat';

  // Método genérico para enviar la solicitud de video a tu servidor
  Future<Map<String, dynamic>?> generarVideo(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mensaje': prompt, // Usamos la misma llave que Flask espera
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Devolvemos el JSON que ya trae el es_video y video_url configurados en Flask
        return {
          'id': 'server_task_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'COMPLETED',
          'es_video': data['es_video'] ?? false,
          'video_url': data['video_url'] ?? '',
          'respuesta': data['respuesta'] ?? '',
        };
      } else {
        return {
          'id': 'sim_task_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'PENDING',
          'es_video': false,
          'video_url': '',
          'respuesta': '⚠️ Error en el servidor de video.',
        };
      }
    } catch (e) {
      return {
        'id': 'sim_task_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'PENDING',
        'es_video': false,
        'video_url': '',
        'respuesta': '⚠️ Error de conexión al generar el video: $e',
      };
    }
  }

  // Método específico requerido por tu pantalla
  Future<String?> generarVideoRealista(String prompt) async {
    final resultado = await generarVideo(prompt);
    if (resultado != null && resultado.containsKey('video_url') && resultado['es_video'] == true) {
      // Retorna la URL del MP4 para que la UI la pueda leer directamente
      return resultado['video_url'].toString();
    }
    return null;
  }
}