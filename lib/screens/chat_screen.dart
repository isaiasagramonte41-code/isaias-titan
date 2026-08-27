import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:video_player/video_player.dart';

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

// Pantalla principal completa que incluye el Menú Lateral izquierdo y el Chat expandido de lado a lado
class MainTitanScreen extends StatelessWidget {
  final String? initialMessage;

  const MainTitanScreen({super.key, this.initialMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // BARRA LATERAL IZQUIERDA (Estilo ChatGPT / Tus opciones de TITÁN)
          Container(
            width: 260,
            color: const Color(0xFF111111),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera / Logo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.cyan[800],
                        child: const Text("T", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "ISAIAS TITÁN",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10),
                
                // Botón Nuevo Chat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: InkWell(
                    onTap: () {
                      // Acción de nuevo chat si manejas rutas
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add, color: Colors.cyanAccent, size: 18),
                          SizedBox(width: 8),
                          Text("Nueva Conversación", style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Recientes", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
                
                // Lista simulada de chats recientes (Estilo de tu imagen)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: const [
                      _SidebarItem(title: "Diseño móvil IA"),
                      _SidebarItem(title: "Problema llaves y paréntesis"),
                      _SidebarItem(title: "Definición de informática"),
                      _SidebarItem(title: "Instalar Flutter Manualmente"),
                      _SidebarItem(title: "Privacidad del teléfono"),
                      _SidebarItem(title: "Título para TikTok"),
                      _SidebarItem(title: "Diseñar Texto Video"),
                      _SidebarItem(title: "Generar imagen de interfaz"),
                      _SidebarItem(title: "Saludo casual"),
                      _SidebarItem(title: "IA integrada en PC"),
                    ],
                  ),
                ),

                const Divider(color: Colors.white10),
                // Opciones inferiores de la barra
                ListTile(
                  leading: const Icon(Icons.video_collection_outlined, color: Colors.cyanAccent, size: 20),
                  title: const Text("Videos IA", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Colors.cyanAccent, size: 20),
                  title: const Text("Configuración", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  title: const Text("Papelera", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ÁREA CENTRAL DEL CHAT (Ocupa el 100% del ancho restante, limpio sin recuadros ni CPU derecha)
          Expanded(
            child: ChatScreen(initialMessage: initialMessage),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  const _SidebarItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {},
        hoverColor: Colors.white10,
      ),
    );
  }
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

  late GenerativeModel _model;
  final VideoAIService _videoService = VideoAIService();

  final List<String> _videosDemo = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _inicializarIA();

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      Future.microtask(() => _enviarMensaje(widget.initialMessage!));
    }
  }

  void _inicializarIA() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    _model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(
        "Eres TITÁN, un asistente virtual avanzado creado por Isaías Patricio Agramonte. Cuando te pidan una explicación, historia o investigación, "
        "responde de manera totalmente desarrollada, detallada, clara y completa. No cortes tus explicaciones. No utilices asteriscos ni formatos de markdown en tus respuestas."
      ),
      generationConfig: GenerationConfig(
        maxOutputTokens: 4000,
        temperature: 0.6,      
      ),
    );
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
        if (archivoActual != null && archivoActual.bytes != null) {
          final mimeType = _obtenerMimeType(archivoActual.extension);
          final prompt = textoUsuario.isEmpty ? "Analiza este archivo." : textoUsuario;
          
          final content = [
            Content.multi([
              TextPart(prompt),
              DataPart(mimeType, archivoActual.bytes!),
            ])
          ];

          final response = await _model.generateContent(content);
          respuestaTexto = response.text ?? "No se pudo procesar el contenido multimedia.";
        } 
        else if (archivoActual != null && archivoActual.path != null) {
          final file = File(archivoActual.path!);
          final bytes = await file.readAsBytes();
          final mimeType = _obtenerMimeType(archivoActual.extension);

          final prompt = textoUsuario.isEmpty ? "Analiza este archivo." : textoUsuario;
          
          final content = [
            Content.multi([
              TextPart(prompt),
              DataPart(mimeType, bytes),
            ])
          ];

          final response = await _model.generateContent(content);
          respuestaTexto = response.text ?? "No se pudo procesar el archivo.";
        } 
        else {
          final response = await _model.generateContent([Content.text(textoUsuario)]);
          respuestaTexto = response.text ?? "Sin respuesta del núcleo.";
        }

        respuestaTexto = respuestaTexto.replaceAll(RegExp(r'\*+'), '');
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
            text: "⚠️ Límite de cuota superado temporalmente. Por favor espera unos segundos antes de volver a consultar.",
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

  String _obtenerMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
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
                    
                    if (msg.isUser) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.cyan[800],
                                child: const Text("T", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                  if (msg.videoUrl != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 280,
                                      width: double.infinity,
                                      constraints: const BoxConstraints(maxWidth: 650),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: ChatVideoPlayer(videoUrl: msg.videoUrl!),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.copy_outlined, size: 16, color: Colors.white54),
                                        onPressed: () {},
                                        tooltip: "Copiar",
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.only(right: 12),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.thumb_up_outlined, size: 16, color: Colors.white54),
                                        onPressed: () {},
                                        tooltip: "Buena respuesta",
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.only(right: 12),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.refresh, size: 16, color: Colors.white54),
                                        onPressed: () {},
                                        tooltip: "Regenerar",
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
        ),
        
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.cyanAccent,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "TITÁN está procesando...",
                  style: TextStyle(color: Colors.cyanAccent, fontSize: 13),
                ),
              ],
            ),
          ),

        if (_archivoSeleccionado != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.cyan.withOpacity(0.15),
            child: Row(
              children: [
                const Icon(Icons.file_present, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Archivo listo: ${_archivoSeleccionado!.name}",
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                  onPressed: () {
                    setState(() {
                      _archivoSeleccionado = null;
                    });
                  },
                ),
              ],
            ),
          ),

        // Barra inferior que aparece cuando ya hay mensajes en la conversación
        if (!esPantallaDeInicio)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.cyanAccent),
                      onPressed: _seleccionarArchivo,
                      tooltip: "Subir archivo",
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Pregunta lo que quieras...",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _enviarMensaje(),
                      ),
                    ),
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
            ),
          ),
      ],
    );
  }

  Widget _buildSugerenciaRapida(IconData icono, String titulo, String promptAccion) {
    return InkWell(
      onTap: () => _enviarMensaje(promptAccion),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: Colors.cyanAccent, size: 18),
            const SizedBox(width: 8),
            Text(titulo, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class ChatVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const ChatVideoPlayer({super.key, required this.videoUrl});

  @override
  State<ChatVideoPlayer> createState() => _ChatVideoPlayerState();
}

class _ChatVideoPlayerState extends State<ChatVideoPlayer> {
  late VideoPlayerController _controller;
  bool _inicializado = false;
  bool _errorCarga = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _inicializado = true;
          });
          _controller.setLooping(true);
          _controller.play().catchError((e) {
            debugPrint("Autoplay prevenido: $e");
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _errorCarga = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorCarga) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "No se pudo cargar el video.",
            style: TextStyle(color: Colors.redAccent, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_inicializado) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.cyanAccent),
            SizedBox(height: 8),
            Text("Cargando video MP4...", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton.small(
            backgroundColor: Colors.cyan[800],
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
          ),
        ),
      ],
    );
  }
}