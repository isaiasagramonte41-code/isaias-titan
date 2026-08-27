import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final Function(String)? onMenuSelected; // Se mantiene opcional por compatibilidad

  const TopBar({super.key, this.onMenuSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        border: const Border(
          bottom: BorderSide(color: Colors.cyanAccent, width: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TÍTULO PRINCIPAL EN LA BARRA SUPERIOR
          const Text(
            "ISAIAS TITAN beta",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // (Se eliminaron todos los botones del centro: Chat, Investigación, Análisis, Proyectos, Asistencia, Ajustes)

          // INDICADOR DE NÚCLEO OPERATIVO A LA DERECHA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.green.withOpacity(0.15),
              border: Border.all(color: Colors.greenAccent),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                SizedBox(width: 6),
                Text(
                  "NÚCLEO OPERATIVO",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}