import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class ElevenLabsService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> reproducirVoz(String texto) async {
    final apiKey = dotenv.env['ELEVENLABS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) return;

    // Usamos una voz predeterminada en español (por ejemplo, "Rachel" o "Antoni" optimizadas)
    const voiceId = '21m00Tcm4TlvDq8ikWAM'; 

    final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId');

    try {
      final response = await http.post(
        url,
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': texto,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
          }
        }),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        await _audioPlayer.play(BytesSource(bytes));
      } else {
        debugPrint("Error en ElevenLabs: ${response.body}");
      }
    } catch (e) {
      debugPrint("Excepción al reproducir voz: $e");
    }
  }
}