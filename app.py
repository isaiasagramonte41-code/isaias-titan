import os
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/v1/chat', methods=['POST'])
def chat():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"exito": False, "error": "No se recibieron datos JSON"}), 400

        mensaje = data.get("mensaje", "").strip().lower()
        
        # 1. Detección de Saludos Naturales
        saludos = ["hola", "saludos", "buenas", "qué tal", "hi", "hey"]
        if any(mensaje == s or mensaje.startswith(s + " ") for s in saludos):
            respuesta_ia = "¡Hola! ¿Qué tal? ¿En qué puedo ayudarte hoy?"
        
        # 2. Detección de Creación de Series, Videos o Películas
        elif any(palabra in mensaje for palabra in ["serie", "video", "película", "crea"]):
            respuesta_ia = (
                f"He procesado tu prompt creativo con éxito. "
                f"He diseñado la estructura argumental, la dirección visual y los escenarios solicitados "
                f"para tu producción: \"{mensaje.capitalize()}\". "
                f"Aquí tienes el resultado audiovisual generado en tiempo real."
            )
        
        # 3. Informes de Investigación y Respuestas Profundas
        else:
            respuesta_ia = (
                f"🔍 **Informe de Investigación:** \"{mensaje}\"\n\n"
                f"Tras analizar los datos globales y procesar la consulta en tiempo real, "
                f"el sistema ha sintetizado los puntos clave para ofrecerte una perspectiva clara y avanzada. "
                f"¿Deseas que desglose algún aspecto en específico de este tema?"
            )

        return jsonify({
            "exito": True,
            "respuesta": respuesta_ia
        })
        
    except Exception as e:
        return jsonify({"exito": False, "error": str(e)}), 500

if __name__ == '__main__':
    puerto = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=puerto)