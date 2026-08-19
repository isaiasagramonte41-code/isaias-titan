# motor_ia.py
import os
import requests
from groq import Groq
from runwayml import RunwayML
from elevenlabs.client import ElevenLabs
import PyPDF2
import speech_recognition as sr

# ==========================================
# COLOCA TUS CLAVES API REALES AQUÍ
# ==========================================
GROQ_KEY = "GROQ_API_KEY"
RUNWAY_KEY = "RUNWAY_KEY"
ELEVEN_KEY = "ELEVEN_KEY"

DIR_RENDERS = "renders"
os.makedirs(DIR_RENDERS, exist_ok=True)

def optimizar_prompt_con_groq(idea_usuario):
    """ISAIAS TITAN optimiza ideas para cine y multimedia"""
    try:
        client = Groq(api_key=GROQ_KEY)
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": "Eres ISAIAS TITAN, director de cine y experto en IA. Traduce ideas a prompts técnicos fotorrealistas en inglés."},
                {"role": "user", "content": f"Convierte esta escena en un prompt cinematográfico detallado: {idea_usuario}"}
            ],
            temperature=0.7,
        )
        return completion.choices[0].message.content
    except Exception as e:
        return idea_usuario

def generar_video_runway(prompt_detallado):
    """Genera video profesional con Runway"""
    os.environ["RUNWAYML_API_SECRET"] = RUNWAY_KEY
    client = RunwayML()
    
    task = client.image_to_video.create(
        model="gen4_turbo",
        prompt_image="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1280&auto=format&fit=crop",
        prompt_text=prompt_detallado,
        ratio="1280:720",
        duration=5
    )
    
    task_output = task.wait_for_task_output()
    video_url = task_output.output[0]
    ruta_video = os.path.join(DIR_RENDERS, "serie_escena_titan.mp4")
    
    with open(ruta_video, "wb") as f:
        f.write(requests.get(video_url).content)
        
    return ruta_video

def generar_voz_elevenlabs(texto):
    """Genera locución realista en español"""
    client = ElevenLabs(api_key=ELEVEN_KEY)
    audio = client.generate(
        text=texto,
        voice="Adam", 
        model="eleven_multilingual_v2"
    )
    ruta_audio = os.path.join(DIR_RENDERS, "doblaje_serie.mp3")
    with open(ruta_audio, "wb") as f:
        for chunk in audio:
            f.write(chunk)
    return ruta_audio

def leer_texto_pdf(ruta_pdf):
    """Extrae todo el contenido de texto de un archivo PDF de tareas o clases"""
    texto_extraido = ""
    try:
        with open(ruta_pdf, "rb") as archivo:
            lector = PyPDF2.PdfReader(archivo)
            for pagina in lector.pages:
                texto_extraido += pagina.extract_text() + "\n"
        return texto_extraido
    except Exception as e:
        return f"Error al leer el PDF: {str(e)}"

def escuchar_microfono():
    """Captura la voz del usuario por el micrófono y la convierte en texto"""
    r = sr.Recognizer()
    with sr.Microphone() as source:
        r.adjust_for_ambient_noise(source, duration=0.5)
        audio = r.listen(source)
    try:
        texto = r.recognize_google(audio, language="es-ES")
        return texto
    except sr.UnknownValueError:
        return "No pude entender el audio, intenta de nuevo."
    except sr.RequestError:
        return "Error de conexión con el servicio de voz."