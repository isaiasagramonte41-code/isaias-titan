import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Ya no necesitamos la API key aquí porque está segura en Render.
  // Ahora apuntamos a la ruta de tu servidor.
  final String _backendUrl = 'https://isaias-titan.onrender.com/chat';

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": prompt,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "⚠️ Respuesta vacía recibida de TITÁN.";
      } else {
        print("--- ERROR DEL SERVIDOR ---");
        print("Código: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        return "⚠️ Error del servidor: Código ${response.statusCode}";
      }
    } catch (e) {
      print("Error de conexión: $e");
      return "⚠️ Error de conexión: $e";
    }
  }
}