import 'package:flutter/material.dart';

class TitanCpuPanel extends StatefulWidget {
  const TitanCpuPanel({Key? key}) : super(key: key);

  @override
  State<TitanCpuPanel> createState() => _TitanCpuPanelState();
}

class _TitanCpuPanelState extends State<TitanCpuPanel> {
  // Simulación de métricas dinámicas del sistema
  double _cpuLoad = 34.5;
  double _memoryUsage = 62.1;
  bool _isOptimized = false;

  void _optimizingSystem() {
    setState(() {
      _isOptimized = true;
      _cpuLoad = 12.0;
      _memoryUsage = 45.0;
    });

    // Simulamos un reinicio de métricas después de un momento
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isOptimized = false;
          _cpuLoad = 28.4;
          _memoryUsage = 58.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera del Núcleo protegida contra desbordamiento de píxeles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.memory, color: Colors.cyanAccent, size: 24),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'NÚCLEO TITÁN - CPU',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isOptimized ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isOptimized ? Colors.greenAccent : Colors.cyanAccent,
                  ),
                ),
                child: Text(
                  _isOptimized ? 'OPTIMIZADO' : 'ESTABLE',
                  style: TextStyle(
                    color: _isOptimized ? Colors.greenAccent : Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Medidor de Carga de CPU
          _buildMetricBar(
            label: 'Carga de Procesamiento (CPU)',
            valueText: '${_cpuLoad.toStringAsFixed(1)}%',
            progress: _cpuLoad / 100,
            color: Colors.cyanAccent,
          ),
          const SizedBox(height: 15),

          // Medidor de Memoria Virtual
          _buildMetricBar(
            label: 'Uso de Memoria Neural',
            valueText: '${_memoryUsage.toStringAsFixed(1)}%',
            progress: _memoryUsage / 100,
            color: Colors.purpleAccent,
          ),
          const SizedBox(height: 20),

          // Botón Táctil de Acción Rápida
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.cyanAccent,
                side: const BorderSide(color: Colors.cyanAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.bolt),
              label: const Text('OPTIMIZAR NÚCLEO'),
              onPressed: _optimizingSystem,
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir las barras de progreso
  Widget _buildMetricBar({
    required String label,
    required String valueText,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text(valueText, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF1F2937),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}