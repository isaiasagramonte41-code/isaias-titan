import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'app_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;

  final String _backendUrl = 'https://isaias-titan.onrender.com/chat';
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendMessage(String textToSend) async {
    if (textToSend.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': textToSend});
      _isLoading = true;
    });

    try {
      // Detector inteligente local de series para ofrecer contenido enfocado inmediatamente
      String lowerText = textToSend.toLowerCase();
      if (lowerText.contains("serie") || lowerText.contains("series") || lowerText.contains("ver una serie") || lowerText.contains("recomienda series")) {
        final botMessage = "Aquí tienes una selección de series de acción y misterio disponibles para maratonear:\n\n"
            "1. Código Titán: Temporada 1 (Acción y Operaciones Encubiertas)\n"
            "2. Crónicas de la Noche: (Suspenso y Misterio Urbano)\n"
            "3. Operación Lluvia Negra: (Drama y Thriller Tecnológico)\n\n"
            "Puedes ir a la sección de 'Galería de Acción' en el menú de opciones (+) para reproducir contenido multimedia completo en alta definición al instante.";
        
        setState(() {
          _messages.add({'sender': 'bot', 'message': botMessage});
        });
      } else {
        // Petición estándar al backend en Render
        final response = await http.post(
          Uri.parse(_backendUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppConfig.apiKey}',
          },
          body: jsonEncode({'message': textToSend}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final botMessage = data['reply'] ?? 'Respuesta vacía del servidor';
          setState(() {
            _messages.add({'sender': 'bot', 'message': botMessage});
          });
        } else {
          setState(() {
            _messages.add({'sender': 'bot', 'message': 'Error del servidor: ${response.statusCode}'});
          });
        }
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'message': 'Error de conexión: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _abrirCamara() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (foto != null) {
        setState(() {
          _messages.add({'sender': 'user', 'message': '[Foto tomada desde la cámara: ${foto.name}]'});
        });
        _sendMessage("He tomado una foto: ${foto.path}");
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'message': 'Error al abrir la cámara: $e'});
      });
    }
  }

  void _mostrarMenuOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file, color: Color(0xFF00F0FF)),
                title: const Text('Subir archivo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF00F0FF)),
                title: const Text('Cámara', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _abrirCamara();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Color(0xFF00F0FF)),
                title: const Text('Galería de Acción', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Lógica para galería de acción / videos MP4
                },
              ),
              ListTile(
                leading: const Icon(Icons.movie, color: Color(0xFF00F0FF)),
                title: const Text('General Video', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Lógica para general video
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFF00F0FF)),
                title: const Text('Crear imágenes', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _manejarMicFirmaInvestigacion() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _controller.text = "Investigar sobre nuevas tecnologías";
    } else {
      if (_controller.text.isNotEmpty) {
        final vozTexto = _controller.text;
        _controller.clear();
        _sendMessage("Investigación por voz: $vozTexto");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        title: const Text('Isaías Titan - IA'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF00F0FF).withOpacity(0.2) : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
                    ),
                    child: Text(
                      msg['message'] ?? '',
                      style: const TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: const Color(0xFF121620),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF00F0FF)),
                  onPressed: () => _mostrarMenuOpciones(context),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _isListening ? 'Escuchando investigación...' : 'Escribe un mensaje para TITÁN...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      _sendMessage(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.redAccent : const Color(0xFF00F0FF),
                  ),
                  onPressed: _manejarMicFirmaInvestigacion,
                ),
                const SizedBox(width: 4.0),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00F0FF)),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}