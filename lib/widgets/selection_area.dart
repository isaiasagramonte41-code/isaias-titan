import 'package:flutter/material.dart';

Widget construirMensajeChat(String textoRespuesta) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
    ),
    // SelectionArea permite seleccionar y copiar cualquier parte del texto manteniendo presionado
    child: SelectionArea(
      child: Text(
        textoRespuesta,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    ),
  );
}