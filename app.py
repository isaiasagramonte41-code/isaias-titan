import os
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)
load_dotenv()

# Variables de entorno principales
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "estado": "ACTIVO",
        "sistema": "TITÁN Core",
        "mensaje": "Servidor base limpio y operativo."
    })

@app.route('/chat', methods=['POST'])
def chat():
    try:
        print("--- NUEVA PETICIÓN RECIBIDA ---")
        data = request.get_json(silent=True, force=True)

        if not data:
            return jsonify({"exito": False, "error": "No se recibieron datos JSON"}), 400

        mensaje_original = data.get("mensaje") or data.get("prompt") or data.get("message", "")
        mensaje_original = str(mensaje_original).strip()

        if not mensaje_original:
            return jsonify({"exito": False, "error": "Mensaje vacío"}), 400
        
        if not GEMINI_API_KEY:
            return jsonify({
                "exito": False, 
                "error": "Falta configurar la GEMINI_API_KEY en el entorno."
            }), 500

        # Endpoint directo con la API de Gemini
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key={GEMINI_API_KEY}"
        
        payload = {
            "contents": [
                {
                    "parts": [
                        {
                            "text": (
                                "Eres TITÁN, un asistente de inteligencia artificial avanzado y directo. "
                                f"Responde a la siguiente consulta: {mensaje_original}"
                            )
                        }
                    ]
                }
            ]
        }

        response = requests.post(
            url,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )

        if response.status_code == 200:
            result_json = response.json()
            bot_reply = result_json["candidates"][0]["content"]["parts"][0]["text"]
            
            return jsonify({
                "exito": True,
                "es_video": False,
                "video_url": "",
                "respuesta": bot_reply
            })
        else:
            print("Error en API externa:", response.text)
            return jsonify({
                "exito": False, 
                "error": f"Error del servidor de IA: {response.text}"
            }), 500
        
    except Exception as e:
        print("Excepción interna:", str(e))
        return jsonify({"exito": False, "error": str(e)}), 500

if __name__ == '__main__':
    puerto = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=puerto)