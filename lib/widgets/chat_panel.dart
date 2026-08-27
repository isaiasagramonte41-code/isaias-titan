import 'package:flutter/material.dart';
import 'feature_card.dart';

class ChatPanel extends StatelessWidget {
  const ChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "ISAIAS TITAN",
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.cyanAccent,
                      blurRadius: 25,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Sistema de Asistente personal",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.cyanAccent,
                  ),
                ),
                child: const Column(
                  children: [

                    Text(
                      "Hola, soy ISAIAS TITAN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),

                    Text(
                      "¿Como te puedo ayudar hoy?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 45),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [

                  FeatureCard(
                    icono: Icons.search,
                    titulo: "Investigación",
                    descripcion: "Buscar información usando TITAN y Ollama.",
                  ),

                  FeatureCard(
                    icono: Icons.analytics,
                    titulo: "Análisis",
                    descripcion: "Analizar documentos, textos y datos.",
                  ),

                  FeatureCard(
                    icono: Icons.rocket_launch,
                    titulo: "Proyectos",
                    descripcion: "Crear aplicaciones, webs y sistemas.",
                  ),

                  FeatureCard(
                    icono: Icons.support_agent,
                    titulo: "Asistencia",
                    descripcion: "Resolver dudas y ayudarte en tiempo real.",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}