const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 10000;

// Inicializa el cliente de la API utilizando tu variable de entorno en Render
const ai = new GoogleGenAI({ apiKey: process.env.ISAIAS_API_KEY });

// Ruta principal para verificar que el backend está activo
app.get('/', (req, res) => {
  res.send('¡Isaías Titan Backend está activo y funcionando perfectamente! 🚀');
});

// Ruta que llama tu aplicación de Flutter para hablar con la IA
app.post('/chat', async (req, res) => {
  try {
    const { message } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'El mensaje es obligatorio' });
    }

    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: message,
      config: {
        systemInstruction: "Te llamas TITÁN. Tu creador es Isaías Patricio Agramonte. REGLA ESTRICTA: Cuando te saluden con un 'hola' o similar, responde de forma ultra corta (máximo una línea, ej: '¡Hola! ¿En qué te ayudo?'). No des discursos largos en saludos simples. Si te preguntan quién te creó, di que fue Isaías Patricio Agramonte de forma directa. Jamás menciones a Google.",
      },
    });

    res.json({ reply: response.text });
  } catch (error) {
    console.error('Error al conectar con la IA:', error);
    res.status(500).json({ error: 'Error interno en el servidor del backend' });
  }
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});