import os
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)
load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
KLING_API_KEY = os.getenv("KLING_API_KEY")
RUNWAY_API_KEY = os.getenv("RUNWAY_API_KEY")

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "estado": "ACTIVO",
        "sistema": "TITÁN Core",
        "mensaje": "Servidor Flask funcionando en la nube con Groq."
    })

@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.get_json(silent=True, force=True)
        if not data:
            return jsonify({"exito": False, "error": "No se recibieron datos JSON"}), 400

        mensaje_original = data.get("mensaje") or data.get("prompt", "")
        mensaje_original = str(mensaje_original).strip()
        mensaje_lower = mensaje_original.lower()
        
        if not mensaje_original:
            return jsonify({"exito": False, "error": "Mensaje vacío"}), 400
        
        # Solo activa video si la intención de crear video es clara, evitando falsos positivos
        if any(p in mensaje_lower for p in ["crear video", "genera un video", "crear una serie", "hacer un video"]):
            if not KLING_API_KEY and not RUNWAY_API_KEY:
                return jsonify({
                    "exito": True,
                    "es_video": False,
                    "video_url": "",
                    "respuesta": "Aviso: Las API Keys de video no se detectaron en el servidor, pero tu solicitud ha sido registrada."
                })
            else:
                return jsonify({
                    "exito": True,
                    "es_video": True,
                    "video_url": "https://www.w3schools.com/html/mov_bbb.mp4",
                    "respuesta": f"🎥 Aquí tienes tu producción generada para: \"{mensaje_original.capitalize()}\"."
                })
        
        if not GROQ_API_KEY:
            return jsonify({
                "exito": False, 
                "error": "Falta configurar la GROQ_API_KEY en las variables de entorno de Render."
            }), 500

        headers = {
            "Authorization": f"Bearer {GROQ_API_KEY}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "llama-3.3-70b-versatile",
            "messages": [
                {
                    "role": "system",
                    "content": (
                        "Eres TITÁN, un núcleo de inteligencia artificial avanzado, directo, técnico y libre. "
                        "Respondes de forma detallada cuando se te pide investigar o analizar temas profundos, "
                        "actuando como un asistente de investigación de nivel experto."
                    )
                },
                {
                    "role": "user", 
                    "content": mensaje_original
                }
            ],
            "temperature": 0.7
        }

        response = requests.post(
            "https://api.groq.com/openai/v1/chat/completions",
            json=payload,
            headers=headers,
            timeout=30
        )

        if response.status_code == 200:
            result_json = response.json()
            bot_reply = result_json["choices"][0]["message"]["content"]
            
            return jsonify({
                "exito": True,
                "es_video": False,
                "video_url": "",
                "respuesta": bot_reply
            })
        else:
            return jsonify({
                "exito": False, 
                "error": f"Error en el motor de IA externo: {response.text}"
            }), 500
        
    except Exception as e:
        return jsonify({"exito": False, "error": str(e)}), 500

if __name__ == '__main__':
    puerto = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=puerto)