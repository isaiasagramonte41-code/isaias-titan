import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;

  const ChatInput({
    super.key,
    required this.onSend,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController controller = TextEditingController();

  void enviarMensaje() {
    final texto = controller.text.trim();

    if (texto.isEmpty) return;

    widget.onSend(texto);

    controller.clear();
  }

  Widget botonIcono({
    required IconData icono,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icono,
          color: Colors.cyanAccent,
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

          botonIcono(
            icono: Icons.attach_file,
            tooltip: "Adjuntar archivo",
            onPressed: () {},
          ),

          botonIcono(
            icono: Icons.image,
            tooltip: "Analizar imagen",
            onPressed: () {},
          ),

          botonIcono(
            icono: Icons.mic,
            tooltip: "Hablar con TITAN",
            onPressed: () {},
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
                hintText: "Pregunta lo que quieras a ISAIAS TITAN...",
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