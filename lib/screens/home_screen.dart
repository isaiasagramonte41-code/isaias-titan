import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../widgets/titan_cpu_panel.dart';

import 'chat_screen.dart';
import 'settings_screen.dart';
import '../services/video_ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentSection = "Nueva Conversación";
  String? _mensajeInicialPendiente;

  void _handleNavigation(String title) {
    setState(() {
      _currentSection = title;

      if (title == "Nueva Conversación") {
        _mensajeInicialPendiente = null;
      }
    });

    if (title == "Nueva Conversación") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✨ Nueva conversación iniciada con TITÁN"),
        ),
      );
    } else if (title == "Papelera") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🗑️ Papelera seleccionada."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Fondo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Sidebar(
                onItemSelected: _handleNavigation,
              ),
              Expanded(
                child: Column(
                  children: [
                    TopBar(
                      onMenuSelected: _handleNavigation,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.cyanAccent.withOpacity(0.3),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: _getDynamicScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const SizedBox(
                              width: 320,
                              child: TitanCpuPanel(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDynamicScreen() {
    switch (_currentSection) {
      case "Nueva Conversación":
        return BienvenidaTitanScreen(
          onEnviar: (texto) {
            setState(() {
              _mensajeInicialPendiente = texto;
              _currentSection = "Chat";
            });
          },
        );

      case "Chat":
        return ChatScreen(
          initialMessage: _mensajeInicialPendiente,
        );

      case "Investigación":
      case "Investigación IA":
        return const InvestigationScreen();

      case "Análisis":
        return const AnalysisScreen();

      case "Proyectos":
        return const ProjectsScreen();

      case "Asistencia":
        return const AssistanceScreen();

      case "Videos IA":
        return const VideosIAScreen();

      case "Internet":
        return const InternetScreen();

      case "Ajustes":
      case "Configuración":
        return const SettingsScreen();

      case "Papelera":
        return const TrashScreen();

      default:
        return ChatScreen(
          initialMessage: _mensajeInicialPendiente,
        );
    }
  }
}

class BienvenidaTitanScreen extends StatefulWidget {
  final ValueChanged<String> onEnviar;

  const BienvenidaTitanScreen({
    super.key,
    required this.onEnviar,
  });

  @override
  State<BienvenidaTitanScreen> createState() =>
      _BienvenidaTitanScreenState();
}

class _BienvenidaTitanScreenState extends State<BienvenidaTitanScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  bool _tieneTexto = false;

  @override
  void initState() {
    super.initState();
    _mensajeController.addListener(() {
      if (!mounted) return;
      setState(() {
        _tieneTexto = _mensajeController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;
    widget.onEnviar(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          const Icon(
            Icons.smart_toy_outlined,
            color: Colors.cyanAccent,
            size: 70,
          ),
          const SizedBox(height: 15),
          const Text(
            "ISAIAS TITAN",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Núcleo de Inteligencia Artificial listo para operar.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "¿En qué puedo ayudarte hoy?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.cyanAccent,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Escribe un mensaje para TITAN...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.mic,
                    color: Colors.cyanAccent,
                  ),
                  onPressed: () {},
                ),
                if (_tieneTexto)
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.cyanAccent,
                    ),
                    onPressed: _enviar,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InvestigationScreen extends StatelessWidget {
  const InvestigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TitanSection(
      icon: Icons.search,
      title: "INVESTIGACIÓN",
      description: "Módulo de investigación de TITAN.",
      message: "Aquí conectaremos el motor de búsqueda y las herramientas de investigación.",
    );
  }
}

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TitanSection(
      icon: Icons.analytics_outlined,
      title: "ANÁLISIS",
      description: "Procesamiento y análisis de información.",
      message: "Aquí podremos analizar textos, datos, archivos y resultados.",
    );
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TitanSection(
      icon: Icons.folder_open,
      title: "PROYECTOS",
      description: "Gestión inteligente de proyectos.",
      message: "Aquí podremos crear, organizar y continuar proyectos de TITAN.",
    );
  }
}

class AssistanceScreen extends StatelessWidget {
  const AssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TitanSection(
      icon: Icons.support_agent,
      title: "ASISTENCIA",
      description: "Centro de asistencia de TITAN.",
      message: "Aquí podrás utilizar TITAN como asistente para tus tareas.",
    );
  }
}

class InternetScreen extends StatelessWidget {
  const InternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TitanSection(
      icon: Icons.public,
      title: "INTERNET",
      description: "Conexión con herramientas de información web.",
      message: "El módulo de Internet está preparado para conectar posteriormente el motor de búsqueda.",
    );
  }
}

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TitanSection(
      icon: Icons.delete_outline,
      title: "PAPELERA",
      description: "Conversaciones eliminadas.",
      message: "La papelera todavía no contiene conversaciones.",
    );
  }
}

class _TitanSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String message;

  const _TitanSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 75),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.3),
                ),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA DE VIDEOS IA CON REPRODUCTOR REAL + RUNWAY
// ==========================================
class VideosIAScreen extends StatefulWidget {
  const VideosIAScreen({super.key});

  @override
  State<VideosIAScreen> createState() => _VideosIAScreenState();
}

class _VideosIAScreenState extends State<VideosIAScreen> {
  String _categoriaSeleccionada = "Acción";
  final VideoAIService _videoAIService = VideoAIService();
  bool _estaGenerando = false;

  final List<String> _categorias = [
    "Acción",
    "Romance",
    "Sci-Fi",
    "Terror",
    "Comedia",
  ];

  final Map<String, List<String>> _videosPorCategoria = {
    "Acción": [
      "Cyber-Batalla Final",
      "Persecución en Neo-Tokio",
      "Infiltración Robot",
      "Rescate de Datos",
      "El Último Guerrero",
      "Duelo de Titanes",
    ],
    "Romance": [
      "Amores Digitales",
      "Conexión Cuántica",
      "El Algoritmo del Corazón",
      "Cena Virtual",
    ],
    "Sci-Fi": [
      "El Origen de la IA",
      "Viaje a Marte",
      "Colonia Espacial Omega",
      "El Multiverso",
      "Bio-Hacking",
    ],
    "Terror": [
      "Error Crítico",
      "La Sombra del Servidor",
      "Pesadilla Neuronal",
    ],
    "Comedia": [
      "Depuración Fallida",
      "El Robot que se Ríe",
      "Fallos Técnicos Graciosos",
    ],
  };

  void _reproducirVideo(BuildContext context, String titulo) {
    showDialog(
      context: context,
      builder: (context) => _DialogoReproductorVideo(titulo: titulo),
    );
  }

  void _mostrarModalCrearVideo(BuildContext context) {
    final TextEditingController promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "CREAR VIDEO REALISTA (RUNWAY)",
          style: TextStyle(color: Colors.cyanAccent, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Describe la escena que TITÁN convertirá en video hiperrealista en 4K:",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: promptController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Ej: Un astronauta caminando en marte...",
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () async {
              String textoPrompt = promptController.text.trim();
              if (textoPrompt.isEmpty) return;

              Navigator.pop(context);
              setState(() => _estaGenerando = true);
              
              String? taskId = await _videoAIService.generarVideoRealista(textoPrompt);

              setState(() => _estaGenerando = false);

              if (!mounted) return;
              
              if (taskId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✨ ¡Video en proceso! ID: $taskId")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("❌ Error al conectar con Runway.")),
                );
              }
            },
            child: const Text("Generar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videosActuales = _videosPorCategoria[_categoriaSeleccionada] ?? [];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "GALERÍA DE VIDEOS - NÚCLEO IA",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                  side: const BorderSide(color: Colors.cyanAccent),
                ),
                onPressed: _estaGenerando ? null : () => _mostrarModalCrearVideo(context),
                icon: _estaGenerando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, color: Colors.cyanAccent),
                label: Text(
                  _estaGenerando ? "Procesando..." : "Crear Video IA",
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categorias.map((categoria) {
              final estaActiva = categoria == _categoriaSeleccionada;

              return ChoiceChip(
                label: Text(
                  categoria,
                  style: TextStyle(
                    color: estaActiva ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: estaActiva,
                selectedColor: Colors.cyanAccent,
                backgroundColor: Colors.blue.withOpacity(0.3),
                onSelected: (_) {
                  setState(() {
                    _categoriaSeleccionada = categoria;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3,
              ),
              itemCount: videosActuales.length,
              itemBuilder: (context, index) {
                final tituloVideo = videosActuales[index];

                return GestureDetector(
                  onTap: () => _reproducirVideo(context, tituloVideo),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[900]?.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.cyanAccent,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tituloVideo,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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

class _DialogoReproductorVideo extends StatefulWidget {
  final String titulo;
  const _DialogoReproductorVideo({required this.titulo});

  @override
  State<_DialogoReproductorVideo> createState() =>
      __DialogoReproductorVideoState();
}

class __DialogoReproductorVideoState extends State<_DialogoReproductorVideo> {
  late VideoPlayerController _controller;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-beginners-assets/bee.mp4'),
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _inicializado = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Text(
        widget.titulo,
        style: const TextStyle(color: Colors.cyanAccent),
      ),
      content: SizedBox(
        width: 450,
        height: 280,
        child: _inicializado
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: Colors.cyanAccent.withOpacity(0.8),
                      size: 64,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.cyanAccent,
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cerrar",
            style: TextStyle(color: Colors.cyanAccent),
          ),
        ),
      ],
    );
  }
}