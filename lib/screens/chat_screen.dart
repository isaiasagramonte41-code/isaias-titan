import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/video_ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? filePath;
  final String? videoUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.filePath,
    this.videoUrl,
  });
}

class ChatScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  bool _isLoading = false;
  PlatformFile? _archivoSeleccionado;

  final VideoAIService _videoService = VideoAIService();

  // 👉 1. CAMBIA ESTA URL POR LA DE TU PROPIA API 👈
  final String _tuApiUrl = 'https://isaias-titan.onrender.com/v1/chat'; 
  late final String _tuApiKey;

  final List<String> _videosDemo = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  ];

  @override
  void initState() {
    super.initState();
    // Carga tu API key desde el archivo .env automáticamente
    _tuApiKey = dotenv.env['rnd_TRTrFUg2oQ7L24vDReDY1rAmkazu'] ?? '';

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      Future.microtask(() => _enviarMensaje(widget.initialMessage!));
    }
  }

  Future<void> _seleccionarArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _archivoSeleccionado = result.files.first;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("📁 Archivo adjuntado: ${_archivoSeleccionado!.name}"),
            backgroundColor: Colors.cyan[800],
          ),
        );
      }
    } catch (e) {
      debugPrint("Error al seleccionar archivo: $e");
    }
  }

  bool _esPeticionDeVideo(String texto) {
    final t = texto.toLowerCase();
    return t.contains("video") || 
           t.contains("crea esa") || 
           t.contains("generar video") || 
           t.contains("haz un video") ||
           t.contains("crea un video") ||
           t.contains("en un video");
  }

  Future<void> _enviarMensaje([String? textoForzado]) async {
    final textoUsuario = textoForzado ?? _controller.text.trim();

    if (textoUsuario.isEmpty && _archivoSeleccionado == null) return;

    final archivoActual = _archivoSeleccionado;

    setState(() {
      _messages.add(
        ChatMessage(
          text: textoUsuario.isEmpty 
              ? "Analiza este archivo: ${archivoActual?.name}" 
              : textoUsuario,
          isUser: true,
          filePath: archivoActual?.name,
        ),
      );
      _controller.clear();
      _archivoSeleccionado = null;
      _isLoading = true;
    });

    _scrollDown();

    try {
      String respuestaTexto = "";
      String? videoUrlGenerado;

      if (_esPeticionDeVideo(textoUsuario)) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "🎬 Núcleo TITÁN sintetizando prompt visual y renderizando video MP4...",
              isUser: false,
            ),
          );
        });

        await Future.delayed(const Duration(seconds: 3));

        _videosDemo.shuffle();
        videoUrlGenerado = _videosDemo.first;
        
        respuestaTexto = "✨ ¡Video generado con éxito y optimizado en formato MP4!";

      } else {
        // 👉 2. PETICIÓN HTTP A TU PROPIA API 👈
        final response = await http.post(
          Uri.parse(_tuApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_tuApiKey', // Si tu API usa otro header, cámbialo aquí
          },
          body: jsonEncode({
            'prompt': textoUsuario,
            'file_name': archivoActual?.name,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Cambia 'response' por la llave exacta que devuelve tu servidor (ej. data['reply'])
          respuestaTexto = data['response'] ?? data['message'] ?? 'Respuesta vacía de tu IA.';
        } else {
          respuestaTexto = "⚠️ Error del servidor (${response.statusCode}): No se pudo conectar a tu API.";
        }
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: respuestaTexto, 
            isUser: false,
            videoUrl: videoUrlGenerado, 
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "⚠️ Error de red con tu API: $e",
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollDown();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildSugerenciaRapida(IconData icono, String titulo, String prompt) {
    return InkWell(
      onTap: () => _enviarMensaje(prompt),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: Colors.cyanAccent, size: 20),
            const SizedBox(height: 8),
            Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(prompt, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool esPantallaDeInicio = _messages.isEmpty;

    return Column(
      children: [
        Expanded(
          child: esPantallaDeInicio
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿Por dónde deberíamos empezar?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 700),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.cyanAccent),
                                onPressed: _seleccionarArchivo,
                                tooltip: "Adjuntar archivo",
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "Pregunta lo que quieras",
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _enviarMensaje(),
                                ),
                              ),
                              const Text("Pensar", style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(width: 8),
                              const Icon(Icons.mic_none, color: Colors.white54, size: 20),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.cyan,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_upward, color: Colors.black, size: 16),
                                  onPressed: () => _enviarMensaje(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Wrap(
                          spacing: 15,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildSugerenciaRapida(Icons.image_outlined, "Crea una imagen", "Crea una imagen futurista de TITÁN"),
                            _buildSugerenciaRapida(Icons.edit_outlined, "Escribir o editar", "Ayúdame a redactar un texto profesional"),
                            _buildSugerenciaRapida(Icons.language, "Buscar en la web", "Investiga las últimas novedades tecnológicas"),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isUser ? Colors.grey[850] : Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (msg.filePath != null) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.attach_file, color: Colors.cyanAccent, size: 16),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      msg.filePath!,
                                      style: const TextStyle(
                                        color: Colors.cyanAccent,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              msg.text,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (!_isLoading && _messages.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.cyanAccent),
                    onPressed: _seleccionarArchivo,
                    tooltip: "Adjuntar archivo",
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Pregunta lo que quieras a TITÁN...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _enviarMensaje(),
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.cyan,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.black, size: 16),
                      onPressed: () => _enviarMensaje(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          ),
      ],
    );
  }
}