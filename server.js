const express = require('express');
const app = express();
const path = require('path');
const PORT = process.env.PORT || 3000;

// Esto le dice a Express que busque archivos estáticos en la carpeta raíz (o donde tengas tu HTML)
app.use(express.static(path.join(__dirname)));

// Ruta principal que carga tu archivo de interfaz (ajusta 'index.html' si tu archivo se llama diferente)
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});