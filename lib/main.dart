import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

// --- Gestor Central de API Keys con versiones funcionales ---
class TitanApiManager {
  static String get geminiKey => dotenv.env['ISAIAS_API_KEY'] ?? '';
  static String get klingKey => dotenv.env['KLING_API_KEY'] ?? '';
  static String get runwayKey => dotenv.env['RUNWAY_API_KEY'] ?? '';

  // Conexión para generar contenido mediante Kling AI (Versión v1 oficial)
  static Future<String> generarVideoKling(String prompt) async {
    if (klingKey.isEmpty) return "Error: Falta KLING_API_KEY en .env";
    try {
      final response = await http.post(
        Uri.parse('https://api.klingai.com/v1/videos/text2video'),
        headers: {
          'Authorization': 'Bearer $klingKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'model_name': 'kling-v1',
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['video_url'] ?? '';
      }
      return "Error en la respuesta de Kling: ${response.statusCode}";
    } catch (e) {
      return "Excepción conectando con Kling: $e";
    }
  }

  // Conexión para generar videos mediante Runway Gen-3 (Versión gen3a_turbo)
  static Future<String> generarVideoRunway(String prompt) async {
    if (runwayKey.isEmpty) return "Error: Falta RUNWAY_API_KEY en .env";
    try {
      final response = await http.post(
        Uri.parse('https://api.dev.runwayml.com/v1/image_to_video'),
        headers: {
          'Authorization': 'Bearer $runwayKey',
          'Content-Type': 'application/json',
          'X-Runway-Version': '2024-11-06',
        },
        body: jsonEncode({
          'promptText': prompt,
          'model': 'gen3a_turbo',
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['output']?[0] ?? '';
      }
      return "Error en la respuesta de Runway: ${response.statusCode}";
    } catch (e) {
      return "Excepción conectando con Runway: $e";
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TITÁN AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF040814),
      ),
      home: const MainTitanScreen(),
    );
  }
}

// --- Modelos de datos auxiliares ---
class VideoAccionItem {
  final String titulo;
  final String categoria;
  final String resolucion;
  final String descripcion;
  final String videoUrl;

  VideoAccionItem({
    required this.titulo,
    required this.categoria,
    required this.resolucion,
    required this.descripcion,
    required this.videoUrl,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? filePath;
  final Uint8List? fileBytes;
  final String? fileType;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.filePath,
    this.fileBytes,
    this.fileType,
  });
}

class ModeloChat {
  final String id;
  final String titulo;
  final List<ChatMessage> mensajes;

  ModeloChat({
    required this.id,
    required this.titulo,
    required this.mensajes,
  });
}

// --- Pantalla principal con el Drawer Reorganizado ---
class MainTitanScreen extends StatefulWidget {
  const MainTitanScreen({super.key});

  @override
  State<MainTitanScreen> createState() => _MainTitanScreenState();
}

class _MainTitanScreenState extends State<MainTitanScreen> {
  int _indiceActual = 0; 
  List<ModeloChat> _historialChats = [];
  ModeloChat? _chatActivo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040814),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070E22),
        title: Text(
          _indiceActual == 1
              ? 'GALERÍA DE ACCIÓN Y GÉNEROS'
              : _indiceActual == 2
                  ? 'GENERAL VIDEO'
                  : 'TITÁN AI',
          style: const TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00F0FF)),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF070E22),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0A1B38),
                border: Border(bottom: BorderSide(color: Color(0xFF102A45))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'TITÁN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _chatActivo = null;
                        _indiceActual = 0;
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('NUEVO CHAT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A223E),
                      foregroundColor: const Color(0xFF00F0FF),
                      side: const BorderSide(color: Color(0xFF00F0FF)),
                      minimumSize: const Size(double.infinity, 36),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFF00F0FF)),
              title: const Text('Chat Principal', style: TextStyle(color: Colors.white70)),
              onTap: () {
                setState(() { _indiceActual = 0; });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined, color: Color(0xFF00F0FF)),
              title: const Text('Galería de Acción', style: TextStyle(color: Colors.white70)),
              onTap: () {
                setState(() { _indiceActual = 1; });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie_creation_outlined, color: Color(0xFF00F0FF)),
              title: const Text('General Video', style: TextStyle(color: Colors.white70)),
              onTap: () {
                setState(() { _indiceActual = 2; });
                Navigator.pop(context);
              },
            ),
            const Divider(color: Color(0xFF102A45), height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'CONVERSACIONES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00F0FF),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (_historialChats.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('No hay conversaciones guardadas', style: TextStyle(color: Colors.white38, fontSize: 12)),
              )
            else
              for (var chat in _historialChats)
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.white54, size: 18),
                  title: Text(chat.titulo, style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis),
                  onTap: () {
                    setState(() {
                      _chatActivo = chat;
                      _indiceActual = 0;
                    });
                    Navigator.pop(context);
                  },
                ),
          ],
        ),
      ),
      body: _obtenerVistaActual(),
    );
  }

  Widget _obtenerVistaActual() {
    if (_indiceActual == 1) {
      return const GaleriaAccionScreen();
    } else if (_indiceActual == 2) {
      return const GeneralVideoScreen();
    } else {
      return ChatScreen(
        chatInicial: _chatActivo,
        onMensajesActualizados: (primerMensaje, mensajes) {
          setState(() {
            if (_chatActivo == null) {
              final nuevoChat = ModeloChat(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                titulo: primerMensaje.length > 25 ? '${primerMensaje.substring(0, 25)}...' : primerMensaje,
                mensajes: mensajes,
              );
              _historialChats.add(nuevoChat);
              _chatActivo = nuevoChat;
            }
          });
        },
      );
    }
  }
}

// --- Pantalla Galería de Acción ---
class GaleriaAccionScreen extends StatelessWidget {
  const GaleriaAccionScreen({super.key});

  static final List<VideoAccionItem> listaVideos = [
    VideoAccionItem(
      titulo: "Combate de Artes Marciales Mixtas",
      categoria: "Pelea / Acción Real",
      resolucion: "1080P HD",
      descripcion: "Demostración de intercambio de golpes dinámicos en ring profesional.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    ),
    VideoAccionItem(
      titulo: "Persecución Nocturna en Autopista",
      categoria: "Acción / Suspenso",
      resolucion: "4K ULTRA",
      descripcion: "Escena de alta tensión con vehículos deportivos a máxima velocidad.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    ),
    VideoAccionItem(
      titulo: "Sombra en el Pasillo Oscuro",
      categoria: "Terror / Misterio",
      resolucion: "1080P HD",
      descripcion: "Ambiente tétrico y cinematográfico diseñado para pruebas de terror psicológico.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXPLORADOR MULTIMEDIA: ACCIÓN Y TERROR',
            style: TextStyle(color: Color(0xFF00F0FF), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecciona un contenido multimedia compatible para reproducir en streaming directo dentro de la app.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: listaVideos.length,
              itemBuilder: (context, index) {
                final video = listaVideos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070E22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF102A45), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1B38),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00F0FF), width: 1),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF00F0FF), size: 26),
                    ),
                    title: Text(video.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(video.categoria, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(video.descripcion, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A223E),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF00F0FF)),
                      ),
                      child: Text(video.resolucion, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => _DialogoReproductorVideo(video: video),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Pantalla General Video ---
class GeneralVideoScreen extends StatefulWidget {
  const GeneralVideoScreen({super.key});

  @override
  State<GeneralVideoScreen> createState() => _GeneralVideoScreenState();
}

class _GeneralVideoScreenState extends State<GeneralVideoScreen> {
  final List<VideoAccionItem> _videosGenerales = [
    VideoAccionItem(
      titulo: "Presentación Corporativa TITÁN",
      categoria: "General / Tecnológico",
      resolucion: "1080P HD",
      descripcion: "Video de demostración general de las capacidades analíticas de la plataforma.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    ),
  ];

  void _agregarVideoLocal() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.isNotEmpty) {
      final archivo = result.files.first;
      setState(() {
        _videosGenerales.add(
          VideoAccionItem(
            titulo: archivo.name,
            categoria: "Video Local / Personal",
            resolucion: "HD",
            descripcion: "Archivo multimedia cargado desde el dispositivo del usuario.",
            videoUrl: archivo.path ?? "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REPOSITORIO GENERAL DE VÍDEOS',
                    style: TextStyle(color: Color(0xFF00F0FF), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Administra, reproduce y carga tus propios archivos de vídeo multimedia.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A223E),
                  foregroundColor: const Color(0xFF00F0FF),
                  side: const BorderSide(color: Color(0xFF00F0FF)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: _agregarVideoLocal,
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('SUBIR VÍDEO'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _videosGenerales.length,
              itemBuilder: (context, index) {
                final video = _videosGenerales[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070E22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF102A45), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1B38),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00F0FF), width: 1),
                      ),
                      child: const Icon(Icons.movie_rounded, color: Color(0xFF00F0FF), size: 26),
                    ),
                    title: Text(video.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(video.categoria, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(video.descripcion, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A223E),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF00F0FF)),
                      ),
                      child: Text(video.resolucion, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => _DialogoReproductorVideo(video: video),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Diálogo Reproductor de Video ---
class _DialogoReproductorVideo extends StatefulWidget {
  final VideoAccionItem video;
  const _DialogoReproductorVideo({required this.video});

  @override
  State<_DialogoReproductorVideo> createState() => _DialogoReproductorVideoState();
}

class _DialogoReproductorVideoState extends State<_DialogoReproductorVideo> {
  VideoPlayerController? _controller;
  bool _inicializado = false;
  bool _errorCarga = false;

  @override
  void initState() {
    super.initState();
    _inicializarVideo();
  }

  void _inicializarVideo() {
    String urlReproduccion = widget.video.videoUrl;

    _controller = VideoPlayerController.networkUrl(Uri.parse(urlReproduccion))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _inicializado = true;
          _errorCarga = false;
          _controller?.play();
        });
      }).catchError((error) {
        if (!mounted) return;
        setState(() {
          _errorCarga = true;
        });
        debugPrint("Error crítico en reproductor web: $error");
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF070E22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
      ),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1B38),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF00F0FF)),
                  ),
                  child: Text(widget.video.resolucion, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.video.titulo,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF102A45)),
              ),
              child: _errorCarga
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                          const SizedBox(height: 8),
                          const Text("El navegador bloqueó el flujo multimedia.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A223E), foregroundColor: const Color(0xFF00F0FF)),
                            onPressed: () {
                              setState(() {
                                _errorCarga = false;
                                _inicializado = false;
                              });
                              _inicializarVideo();
                            },
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text("Reintentar"),
                          ),
                        ],
                      ),
                    )
                  : (_inicializado && _controller != null)
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                            Positioned(
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                    color: const Color(0xFF00F0FF).withOpacity(0.85),
                                    size: 54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                                    });
                                  },
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Colors.black54,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: const Color(0xFF00F0FF),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: VideoProgressIndicator(
                                      _controller!,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                        playedColor: Color(0xFF00F0FF),
                                        bufferedColor: Colors.white24,
                                        backgroundColor: Colors.white10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
                        ),
            ),
            const SizedBox(height: 12),
            Text(widget.video.categoria, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.video.descripcion, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// --- Pantalla de Chat ---
class ChatScreen extends StatefulWidget {
  final ModeloChat? chatInicial;
  final Function(String, List<ChatMessage>) onMensajesActualizados;

  const ChatScreen({super.key, this.chatInicial, required this.onMensajesActualizados});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<ChatMessage> _messages;
  
  bool _isLoading = false;
  PlatformFile? _archivoSeleccionado;
  Uint8List? _bytesArchivoSeleccionado;
  String? _tipoArchivoSeleccionado;

  late GenerativeModel _model;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _messages = widget.chatInicial != null ? List.from(widget.chatInicial!.mensajes) : [
      ChatMessage(
        text: "¡Hola! Soy TITÁN, tu asistente de inteligencia artificial avanzada.\n\n¿En qué puedo ayudarte hoy? Puedes hacerme cualquier consulta o compartir conmigo imágenes, vídeos de acción o documentos para analizarlos con total precisión y detalle.",
        isUser: false,
      )
    ];
    _inicializarIA();
    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => setState(() => _isListening = false),
    );
    setState(() {});
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El reconocimiento de voz no está disponible en este dispositivo')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
        },
        localeId: 'es_ES',
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
    final apiKey = TitanApiManager.geminiKey;
    _model = GenerativeModel(
      model: 'gemini-3.6-flash', // <--- Tu versión restaurada y funcional
      apiKey: apiKey,
      systemInstruction: Content.text(
        "Eres TITÁN, un asistente de inteligencia artificial avanzada. Al redactar tus respuestas, NO utilices símbolos de asteriscos ni marcas de formato Markdown (como **, *, ###). Presenta el texto siempre limpio, ordenado y formateado mediante párrafos claros o guiones sencillos."
      ),
    );
  }

  String _limpiarTextoMarkdown(String texto) {
    return texto
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('###', '')
        .replaceAll('##', '')
        .replaceAll('#', '');
  }

  void _mostrarOpcionesMas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF070E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: Color(0xFF00F0FF), width: 1),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.attach_file, color: Color(0xFF00F0FF)),
                title: const Text('Subir archivo', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null && result.files.isNotEmpty) {
                    setState(() {
                      _archivoSeleccionado = result.files.first;
                      _bytesArchivoSeleccionado = result.files.first.bytes;
                      _tipoArchivoSeleccionado = 'file';
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF00F0FF)),
                title: const Text('Cámara', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    final bytes = await photo.readAsBytes();
                    setState(() {
                      _archivoSeleccionado = PlatformFile(name: photo.name, size: bytes.length, bytes: bytes);
                      _bytesArchivoSeleccionado = bytes;
                      _tipoArchivoSeleccionado = 'image';
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFF00F0FF)),
                title: const Text('Imagen', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    setState(() {
                      _archivoSeleccionado = PlatformFile(name: image.name, size: bytes.length, bytes: bytes);
                      _bytesArchivoSeleccionado = bytes;
                      _tipoArchivoSeleccionado = 'image';
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty && _archivoSeleccionado == null) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }

    final textoPregunta = texto.isEmpty ? "Analiza este archivo adjunto." : texto;
    final archivoActual = _archivoSeleccionado;
    final bytesActuales = _bytesArchivoSeleccionado;
    final tipoActual = _tipoArchivoSeleccionado;

    setState(() {
      _messages.add(ChatMessage(
        text: textoPregunta,
        isUser: true,
        filePath: archivoActual?.name,
        fileBytes: bytesActuales,
        fileType: tipoActual,
      ));
      _isLoading = true;
      _archivoSeleccionado = null;
      _bytesArchivoSeleccionado = null;
      _tipoArchivoSeleccionado = null;
    });

    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), _irAlFinalDelChat);

    try {
      dynamic content;
      if (bytesActuales != null && (tipoActual == 'image' || tipoActual == 'file')) {
        final ext = archivoActual?.extension ?? 'png';
        content = [
          Content.multi([
            TextPart(textoPregunta),
            DataPart('image/$ext', bytesActuales),
          ])
        ];
      } else {
        content = [Content.text(textoPregunta)];
      }

      final response = await _model.generateContent(content);
      final respuestaCruda = response.text ?? "Análisis completado con éxito.";
      final respuestaLimpia = _limpiarTextoMarkdown(respuestaCruda);

      setState(() {
        _messages.add(ChatMessage(text: respuestaLimpia, isUser: false));
      });

      widget.onMensajesActualizados(textoPregunta, _messages);

    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error de procesamiento: Verifique su API Key en el archivo .env ($e)", isUser: false));
      });
    } finally {
      setState(() { _isLoading = false; });
      Future.delayed(const Duration(milliseconds: 100), _irAlFinalDelChat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Align(
                alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.60),
                  decoration: BoxDecoration(
                    color: msg.isUser ? const Color(0xFF071F3C) : const Color(0xFF070E22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: msg.isUser ? const Color(0xFF00F0FF) : const Color(0xFF102A45),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg.fileBytes != null && (msg.fileType == 'image' || msg.fileType == 'file'))
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: const BoxConstraints(maxHeight: 240, maxWidth: 340),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00F0FF), width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.memory(msg.fileBytes!, fit: BoxFit.cover),
                          ),
                        ),
                      Text(
                        msg.text,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const LinearProgressIndicator(color: Color(0xFF00F0FF), backgroundColor: Color(0xFF070E22)),
        if (_bytesArchivoSeleccionado != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: const Color(0xFF070E22),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00F0FF)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.memory(_bytesArchivoSeleccionado!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Listo para enviar: ${_archivoSeleccionado?.name ?? ''}",
                  style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                  onPressed: () => setState(() {
                    _archivoSeleccionado = null;
                    _bytesArchivoSeleccionado = null;
                    _tipoArchivoSeleccionado = null;
                  }),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFF070E22),
            border: Border(top: BorderSide(color: Color(0xFF102A45), width: 1)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00F0FF), size: 24),
                onPressed: () => _mostrarOpcionesMas(context),
                tooltip: "Opciones adicionales",
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _isListening ? "Escuchando lo que hablas..." : "Escribe un mensaje para TITÁN...",
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _enviarMensaje(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.redAccent : const Color(0xFF00F0FF),
                  size: 22,
                ),
                onPressed: _toggleListening,
                tooltip: "Comando de voz",
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A223E),
                  foregroundColor: const Color(0xFF00F0FF),
                  side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onPressed: _enviarMensaje,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text("ENVIAR", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}