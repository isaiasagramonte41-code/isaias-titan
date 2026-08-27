import 'package:flutter/material.dart';

class NucleusPanel extends StatelessWidget {
  const NucleusPanel({super.key});

  Widget estado(IconData icono, Color color, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icono,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


             const Text(
              "🧠 NÚCLEO TITAN",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  "assets/cpu_core.png",
                  height: 180,
                  fit: BoxFit.contain,
                  ),
                ),
                
          const SizedBox(height: 20),

          const Divider(
            color: Colors.white24,
            height: 35,
          ),

          const Text(
            "Estado Actual",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            children: [

              Icon(
                Icons.circle,
                color: Colors.greenAccent,
                size: 12,
              ),

              SizedBox(width: 8),

              Text(
                "Esperando instrucciones...",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            "Registro del Núcleo",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "✔ Sistema iniciado",
            style: TextStyle(color: Colors.white70),
          ),

          const Text(
            "✔ Memoria cargada",
            style: TextStyle(color: Colors.white70),
          ),

          const Text(
            "✔ Núcleo operativo",
            style: TextStyle(color: Colors.white70),
          ),

          const Text(
            "✔ Esperando actividad",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}