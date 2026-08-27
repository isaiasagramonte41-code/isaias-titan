import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _creativity = 0.7;
  bool _autoRotateKeys = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⚙️ AJUSTES DEL SISTEMA TITÁN",
            style: TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text("Nivel de Creatividad (Temperatura):", style: TextStyle(color: Colors.white)),
          Slider(
            value: _creativity,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: _creativity.toString(),
            onChanged: (val) {
              setState(() {
                _creativity = val;
              });
            },
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text("Rotación automática de las 4 API Keys", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Cambia de llave si ocurre un error de cuota.", style: TextStyle(color: Colors.grey)),
            value: _autoRotateKeys,
            onChanged: (val) {
              setState(() {
                _autoRotateKeys = val;
              });
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("¡Ajustes guardados exitosamente!")),
              );
            },
            child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}