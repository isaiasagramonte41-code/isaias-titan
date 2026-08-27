import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onItemSelected;

  const Sidebar({super.key, required this.onItemSelected});

  Widget item(IconData icon, String texto, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(texto, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      hoverColor: Colors.cyan.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.black.withOpacity(0.45),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage("assets/isaias.png"),
          ),
          const SizedBox(height: 15),
          const Text(
            "TITAN",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: ListView(
              children: [
                // Cambiado a Nueva Conversación y eliminada la lista vieja de conversaciones
                item(Icons.add, "Nueva Conversación", () => onItemSelected("Nueva Conversación")),
                item(Icons.video_library, "Videos IA", () => onItemSelected("Videos IA")),
                item(Icons.language, "Internet", () => onItemSelected("Internet")),
                item(Icons.settings, "Configuración", () => onItemSelected("Ajustes")),
                item(Icons.delete, "Papelera", () => onItemSelected("Papelera")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}