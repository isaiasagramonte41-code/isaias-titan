import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:video_player/video_player.dart';

import 'services/video_ai_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const TitanApp());
}

class TitanApp extends StatelessWidget {
  const TitanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISAIAS TITÁN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        primaryColor: const Color(0xFFFF6B00),
      ),
      home: const MainTitanScreen(),
    );
  }
}

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

class ModeloChat {
  final String id;
  String titulo;
  List<ChatMessage> mensajes;

  ModeloChat({
    required this.id,
    required this.titulo,
    required this.mensajes,
  });
}

class MainTitanScreen extends StatefulWidget {
  const MainTitanScreen({super.key});

  @override
  State<MainTitanScreen> createState() => _MainTitanScreenState();
}

class _MainTitanScreenState extends State<MainTitanScreen> {
  bool _mostrandoGaleriaVideos = false;

  final List<ModeloChat> _historialConversaciones = [];
  ModeloChat? _chatActual;
  Key _chatKey = UniqueKey();

  void _nuevaConversacion() {
    setState(() {
      _mostrandoGaleriaVideos = false;
      _chatActual = null;
      _chatKey = UniqueKey();
    });
  }

  void _abrirGaleriaVideos() {
    setState(() {
      _mostrandoGaleriaVideos = true;
    });
  }

  void _seleccionarChatDelHistorial(ModeloChat chat) {
    setState(() {
      _mostrandoGaleriaVideos = false;
      _chatActual = chat;
      _chatKey = UniqueKey();
    });
  }

  void _guardarOActualizarChat(String primerMensaje, List<ChatMessage> mensajesActuales) {
    if (_chatActual == null) {
      String tituloCorto = primerMensaje.length > 25 
          ? "${primerMensaje.substring(0, 25)}..." 
          : primerMensaje;

      final nuevoChat = ModeloChat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: tituloCorto,
        mensajes: List.from(mensajesActuales),
      );

      setState(() {
        _historialConversaciones.insert(0, nuevoChat);
        _chatActual = nuevoChat;
      });
    } else {
      setState(() {
        _chatActual!.mensajes = List.from(mensajesActuales);
      });
    }
  }

  void _mostrarDialogoRecientes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text("Conversaciones Recientes", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 320,
          child: _historialConversaciones.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Aún no hay conversaciones guardadas. ¡Empieza a chatear!",
                    style: TextStyle(color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _historialConversaciones.length,
                  itemBuilder: (context, index) {
                    final chat = _historialConversaciones[index];
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFFFF6B00)),
                      title: Text(
                        chat.titulo, 
                        style: const TextStyle(color: Color(0xFFE2E8F0)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _seleccionarChatDelHistorial(chat);
                      },
                      hoverColor: const Color(0xFF1F293D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Color(0xFFFF6B00))),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfiguracion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text("Configuración del Sistema", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SwitchListTile(
              title: Text("Modo Creativo Avanzado", style: TextStyle(color: Color(0xFFE2E8F0))),
              value: true,
              activeColor: Color(0xFFFF6B00),
              onChanged: null,
            ),
            SwitchListTile(
              title: Text("Respuestas Extendidas", style: TextStyle(color: Color(0xFFE2E8F0))),
              value: true,
              activeColor: Color(0xFFFF6B00),
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Guardar", style: TextStyle(color: Color(0xFFFF6B00))),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoPapelera(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text("Papelera", style: TextStyle(color: Colors.white)),
        content: const Text("No hay elementos eliminados recientemente.", style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vaciar Papelera", style: TextStyle(color: Color(0xFFFF6B00))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Color(0xFFFF6B00))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF111827),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
                  child: InkWell(
                    onTap: _nuevaConversacion,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F293D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome, color: Color(0xFFFF6B00), size: 16),
                          SizedBox(width: 8),
                          Text(
                            "Nueva Conversación", 
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                _SidebarMenuOption(
                  icon: Icons.video_collection_outlined,
                  title: "Videos con IA",
                  onTap: _abrirGaleriaVideos,
                ),
                _SidebarMenuOption(
                  icon: Icons.settings_outlined,
                  title: "Configuración",
                  onTap: () => _mostrarDialogoConfiguracion(context),
                ),
                _SidebarMenuOption(
                  icon: Icons.delete_outline,
                  title: "Papelera",
                  onTap: () => _mostrarDialogoPapelera(context),
                ),
                _SidebarMenuOption(
                  icon: Icons.history,
                  title: "Recientes",
                  onTap: () => _mostrarDialogoRecientes(context),
                ),
                
                const Spacer(),
                const Divider(color: Colors.white12, height: 1),
                
                Container(
                  padding: const EdgeInsets.all(12.0),
                  color: const Color(0xFF0D1322),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: const Color(0xFFFF6B00),
                        child: const Text("T", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "TITÁN AI",
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Sistema Activo",
                              style: TextStyle(color: Color(0xFFFF6B00), fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _mostrandoGaleriaVideos 
                ? const GaleriaVideosIASScreen() 
                : ChatScreen(
                    key: _chatKey,
                    chatInicial: _chatActual,
                    onMensajesActualizados: _guardarOActualizarChat,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SidebarMenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: const Color(0xFFFF6B00), size: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w400),
        ),
        onTap: onTap,
        hoverColor: const Color(0xFF1F293D),
      ),
    );
  }
}

class GaleriaVideosIASScreen extends StatelessWidget {
  const GaleriaVideosIASScreen({super.key});

  final List<Map<String, String>> _videosVirales = const [
    {
      "titulo": "Persecución Cibernética Neón",
      "categoria": "Acción",
      "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "descripcion": "Generado con Sora / Runway Gen-3 con renderizado realista de vehículos futuristas a alta velocidad."
    },
    {
      "titulo": "Atardecer en Estación Espacial",
      "categoria": "Romance",
      "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "descripcion": "Escena cinematográfica hiperrealista de un encuentro emotivo bajo gravedad cero."
    },
    {
      "titulo": "El Despertar de la Nebulosa",
      "categoria": "Terror",
      "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "descripcion": "Ambiente de misterio y suspenso generado por inteligencia artificial en formato IMAX."
    },
    {
      "titulo": "Viaje al Núcleo de TITÁN",
      "categoria": "Ciencia Ficción",
      "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "descripcion": "Simulación cuántica de estructuras tridimensionales de energía pura."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.video_collection, color: Color(0xFFFF6B00), size: 28),
                SizedBox(width: 12),
                Text(
                  "Galería de Videos Virales con IA",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Explora las producciones más realistas e impactantes generadas por redes neuronales de última generación.",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.4,
                ),
                itemCount: _videosVirales.length,
                itemBuilder: (context, index) {
                  final video = _videosVirales[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                video["titulo"]!,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B00).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFF6B00)),
                                ),
                                child: Text(
                                  video["categoria"]!,
                                  style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            child: ChatVideoPlayer(videoUrl: video["url"]!),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final ModeloChat? chatInicial;
  final Function(String, List<ChatMessage>) onMensajesActualizados;

  const ChatScreen({
    super.key,
    this.chatInicial,
    required this.onMensajesActualizados,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // CONTROLADOR DE SCROLL AUTOMÁTICO
  late List<ChatMessage> _messages;
  
  bool _isLoading = false;
  PlatformFile? _archivoSeleccionado;

  late GenerativeModel _model;

  final List<String> _videosDemo = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _messages = widget.chatInicial != null ? List.from(widget.chatInicial!.mensajes) : [];
    _inicializarIA();
  }

  // Función para mover el scroll hacia abajo automáticamente
  void _irAlFinalDelChat() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _inicializarIA() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(
        "Eres TITÁN, un asistente virtual avanzado. Cuando te pidan una explicación, historia o investigación, "
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
            backgroundColor: const Color(0xFF1F293D),
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
    final texto = textoForzado ?? _controller.text.trim();
    if (texto.isEmpty && _archivoSeleccionado == null) return;

    final mensajeUsuario = ChatMessage(
      text: texto.isEmpty ? "Analiza este archivo: ${_archivoSeleccionado?.name}" : texto,
      isUser: true,
      filePath: _archivoSeleccionado?.name,
    );

    setState(() {
      _messages.add(mensajeUsuario);
      _controller.clear();
      _archivoSeleccionado = null;
      _isLoading = true;
    });

    // Bajamos el scroll al enviar mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) => _irAlFinalDelChat());
    
    if (_messages.length == 1) {
      widget.onMensajesActualizados(mensajeUsuario.text, _messages);
    }

    try {
      String respuestaTexto = "";
      String? videoGeneradoUrl;

      if (_esPeticionDeVideo(texto)) {
        await Future.delayed(const Duration(seconds: 2));
        videoGeneradoUrl = (_videosDemo..shuffle()).first;
        respuestaTexto = "🎬 Video generado con éxito mediante Red Neuronal de Alta Definición.";
      } else {
        final content = [Content.text(texto)];
        final response = await _model.generateContent(content);
        respuestaTexto = response.text ?? "Sin respuesta del modelo.";
      }

      final mensajeIA = ChatMessage(
        text: respuestaTexto,
        isUser: false,
        videoUrl: videoGeneradoUrl,
      );

      setState(() {
        _messages.add(mensajeIA);
        _isLoading = false;
      });

      // Bajamos el scroll al recibir la respuesta de la IA
      WidgetsBinding.instance.addPostFrameCallback((_) => _irAlFinalDelChat());
      widget.onMensajesActualizados(_messages.first.text, _messages);

    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(text: "⚠️ Error de conexión con la IA: $e", isUser: false));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _irAlFinalDelChat());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    // PANTALLA DE BIENVEINDA INICIAL
                    child: Text(
                      "¿Por dónde deberíamos empezar?",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController, // CONEXIÓN DEL SCROLL AUTOMÁTICO
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B00)),
                              ),
                              SizedBox(width: 12),
                              Text("TITÁN está redactando la respuesta...", style: TextStyle(color: Colors.white54, fontSize: 13)),
                            ],
                          ),
                        );
                      }

                      final msg = _messages[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: msg.isUser ? const Color(0xFFFF6B00) : const Color(0xFF131B2E),
                            borderRadius: BorderRadius.circular(12),
                            border: msg.isUser ? null : Border.all(color: const Color(0xFFFF6B00).withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg.filePath != null) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.attach_file, color: Colors.white70, size: 16),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        msg.filePath!,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                              ],
                              Text(
                                msg.text,
                                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                              ),
                              if (msg.videoUrl != null) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 180,
                                  width: 320,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ChatVideoPlayer(videoUrl: msg.videoUrl!),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0B0F19),
            child: Column(
              children: [
                if (_archivoSeleccionado != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF6B00)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.insert_drive_file, color: Color(0xFFFF6B00), size: 16),
                        const SizedBox(width: 8),
                        Text(_archivoSeleccionado!.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() => _archivoSeleccionado = null),
                          child: const Icon(Icons.close, color: Colors.white54, size: 16),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _seleccionarArchivo,
                      icon: const Icon(Icons.attach_file, color: Colors.white54),
                      tooltip: "Adjuntar archivo",
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (val) => _enviarMensaje(),
                        decoration: InputDecoration(
                          hintText: "Investiga algo o crea una serie...",
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF131B2E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B00),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _enviarMensaje(),
                        icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      ),
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
}

class ChatVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ChatVideoPlayer({super.key, required this.videoUrl});

  @override
  State<ChatVideoPlayer> createState() => _ChatVideoPlayerState();
}

class _ChatVideoPlayerState extends State<ChatVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
          );
  }
}