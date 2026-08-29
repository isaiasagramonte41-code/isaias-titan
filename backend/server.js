const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 10000;

// Inicializa el cliente de la API de Gemini utilizando la variable de entorno
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// Ruta principal para que el navegador no dé "Not Found"
app.get('/', (req, res) => {
  res.send('¡Isaías Titan Backend está activo y funcionando perfectamente! 🚀');
});

// Ruta que llamará tu aplicación de Flutter para hablar con la IA
app.post('/chat', async (req, res) => {
  try {
    const { message } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'El mensaje es obligatorio' });
    }

    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: message,
    });

    res.json({ reply: response.text });
  } catch (error) {
    console.error('Error al conectar con Gemini:', error);
    res.status(500).json({ error: 'Error interno en el servidor del backend' });
  }
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});