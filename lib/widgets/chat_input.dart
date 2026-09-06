class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final Function(String)? onInvestigacionVoz;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onInvestigacionVoz,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController controller = TextEditingController();
  bool _isListening = false;

  void enviarMensaje() {
    final texto = controller.text.trim();
    if (texto.isEmpty) return;
    widget.onSend(texto);
    controller.clear();
  }

  // Menú flotante del botón "+" (Subir archivo, Cámara, Crear imágenes)
  void _mostrarMenuMas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.cyanAccent, width: 0.5),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.cyanAccent),
                title: const Text('Subir archivo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Conecta aquí tu selector de archivos
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.cyanAccent),
                title: const Text('Cámara', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Conecta aquí tu lógica de cámara
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.cyanAccent),
                title: const Text('Crear imágenes', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Conecta aquí tu generador de imágenes de la IA
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Micrófono: Lo que hablas se escribe en el input y se manda directo a investigación
  void _manejarMic_Investigacion() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // Aquí activas tu escucha (por ejemplo, speech_to_text)
      // Simulación de texto hablado para prueba rápida:
      controller.text = "Investigar sobre las últimas tendencias de IA";
    } else {
      // Al terminar de hablar, se envía directo
      if (controller.text.isNotEmpty) {
        final textoFinal = controller.text;
        controller.clear();
        if (widget.onInvestigacionVoz != null) {
          widget.onInvestigacionVoz!(textoFinal);
        } else {
          widget.onSend(textoFinal);
        }
      }
    }
  }

  Widget botonIcono({
    required IconData icono,
    required String tooltip,
    required VoidCallback onPressed,
    Color color = Colors.cyanAccent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icono,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        border: const Border(
          top: BorderSide(
            color: Colors.cyanAccent,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.15),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón "+" con el menú desplegable (Subir archivo, Cámara, Crear imágenes)
          botonIcono(
            icono: Icons.add_circle_outline,
            tooltip: "Opciones (Archivo, Cámara, Imágenes)",
            onPressed: () => _mostrarMenuMas(context),
          ),

          // Botón de Micrófono conectado directo a investigación
          botonIcono(
            icono: _isListening ? Icons.mic : Icons.mic_none,
            tooltip: "Hablar para investigación directa",
            color: _isListening ? Colors.redAccent : Colors.cyanAccent,
            onPressed: _manejarMic_Investigacion,
          ),

          botonIcono(
            icono: Icons.language,
            tooltip: "Buscar en Internet",
            onPressed: () {},
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: _isListening ? "Escuchando investigación..." : "Pregunta lo que quieras a ISAIAS TITAN...",
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),
                filled: true,
                fillColor: const Color(0xFF151A22),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => enviarMensaje(),
            ),
          ),

          const SizedBox(width: 15),

          ElevatedButton.icon(
            onPressed: enviarMensaje,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.send),
            label: const Text(
              "ENVIAR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}