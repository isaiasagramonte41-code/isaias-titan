const express = require('express');
const app = express();
const path = require('path');
const PORT = process.env.PORT || 10000;

// Si tu index.html está en la raíz de tu proyecto (fuera de cualquier carpeta), usa esto:
app.use(express.static(path.join(__dirname)));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Nota: Si por el contrario, tu index.html está metido dentro de una carpeta llamada "src",
// cambia las dos líneas de arriba por estas:
// app.use(express.static(path.join(__dirname, 'src')));
// res.sendFile(path.join(__dirname, 'src', 'index.html'));

app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});