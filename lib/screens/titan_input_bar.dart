import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';

class TitanInputBar extends StatefulWidget {
  final Function(String) onSubmitted; // Parámetro para recibir la función de envío / investigación

  const TitanInputBar({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  State<TitanInputBar> createState() => _TitanInputBarState();
}

class _TitanInputBarState extends State<TitanInputBar> {
  final TextEditingController _textController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          // Si el estado cambia a 'notListening' o 'done', podemos procesar lo que se habló
          if (val == 'notListening' || val == 'done') {
            if (_isListening && _lastWords.trim().isNotEmpty) {
              setState(() => _isListening = false);
              widget.onSubmitted(_lastWords.trim()); // ¡Envío automático directo a investigación/chat!
              _lastWords = '';
              _textController.clear();
            }
          }
        },
        onError: (val) => print('onError: $val'),
      );
      
      if (available) {
        setState(() {
          _isListening = true;
          _lastWords = '';
        });
        
        _speech.listen(
          onResult: (val) {
            setState(() {
              _lastWords = val.recognizedWords;
              _textController.text = _lastWords; // Solo visual en la caja mientras habla
            });
            
            // Si el motor detecta que el usuario terminó la frase (finalResult), enviamos de inmediato
            if (val.finalResult && _lastWords.trim().isNotEmpty) {
              _speech.stop();
              setState(() => _isListening = false);
              widget.onSubmitted(_lastWords.trim());
              _lastWords = '';
              _textController.clear();
            }
          },
        );
      }
    } else {
      // Si el usuario vuelve a presionar el micro para detenerlo manualmente
      setState(() => _isListening = false);
      _speech.stop();
      if (_lastWords.trim().isNotEmpty) {
        widget.onSubmitted(_lastWords.trim());
        _lastWords = '';
        _textController.clear();
      }
    }
  }

  void _enviar() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted(text);
      _textController.clear();
    }
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subir Archivo',
                style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.cyanAccent),
                title: const Text('Subir cualquier archivo (Video, Imagen, PDF...)', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    String fileName = result.files.single.name;
                    print("Archivo seleccionado: $fileName");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF0B0F19),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent, size: 28),
            onPressed: () => _showAttachmentMenu(context),
            tooltip: 'Subir archivo',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _enviar(),
              decoration: InputDecoration(
                hintText: _isListening ? 'Escuchando tu comando...' : 'Escribe o usa el micro para investigar...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1F2937),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.redAccent : Colors.cyanAccent,
              size: 28,
            ),
            onPressed: _listen,
            tooltip: 'Hablar para investigar',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.cyanAccent, size: 24),
            onPressed: _enviar,
          ),
        ],
      ),
    );
  }
}