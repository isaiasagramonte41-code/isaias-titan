import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# Inicialización de estado
if "chats" not in st.session_state:
    st.session_state.chats = {"Chat Principal": []}
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Chat Principal"
if "modo" not in st.session_state:
    st.session_state.modo = "💬 Investigar / Chat General"

# --- BARRA LATERAL ---
with st.sidebar:
    st.title("⚡ ISAIAS TITAN")
    
    if st.button("➕ Nuevo Chat", use_container_width=True):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.rerun()

    st.markdown("---")
    st.subheader("🛠️ Modos del Titán")
    
    # Selector de funciones principales
    modo_seleccionado = st.radio(
        "Elige qué quieres hacer:",
        ["💬 Investigar / Chat General", "🖼️ Crear Imagen", "🎬 Texto a Video", "🗣️ Hablar (Voz)"]
    )
    st.session_state.modo = modo_seleccionado

    st.markdown("---")
    st.subheader("💬 Historial de Chats")
    for chat_id in st.session_state.chats.keys():
        if st.button(chat_id, key=chat_id, use_container_width=True):
            st.session_state.chat_actual = chat_id
            st.rerun()

# --- ÁREA CENTRAL ---
st.header(f"🎬 {st.session_state.chat_actual} — [{st.session_state.modo}]")

# Mostrar mensajes del chat actual
for msg in st.session_state.chats[st.session_state.chat_actual]:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# Entrada de mensaje según el modo activo
placeholder_text = {
    "💬 Investigar / Chat General": "¿Qué quieres investigar o preguntar hoy?",
    "🖼️ Crear Imagen": "Describe la imagen épica que deseas generar...",
    "🎬 Texto a Video": "Describe la escena de video que quieres crear...",
    "🗣️ Hablar (Voz)": "Escribe el texto que deseas que el Titán convierta en voz..."
}.get(st.session_state.modo, "Escribe tu idea...")

if prompt := st.chat_input(placeholder_text):
    # 1. Guardar mensaje del usuario
    st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # 2. Generar respuesta basada en el modo activo
    with st.chat_message("assistant"):
        modo = st.session_state.modo
        
        if "Investigar" in modo:
            # Aquí irá tu lógica con Groq/IA para investigar
            respuesta = f"🔍 [Investigación del Titán]: Analizando información sobre '{prompt}'..."
            
        elif "Imagen" in modo:
            # Aquí irá tu lógica para generar imágenes
            respuesta = f"🖼️ [Generador de Imágenes]: Procesando tu solicitud visual para: '{prompt}'..."
            
        elif "Video" in modo:
            # Aquí irá tu lógica para conectar con herramientas de video
            respuesta = f"🎬 [Estudio de Video]: Renderizando escena basada en: '{prompt}'..."
            
        elif "Hablar" in modo:
            # Aquí irá tu lógica de ElevenLabs o voz
            respuesta = f"🗣️ [Motor de Voz]: Generando locución para: '{prompt}'..."
        
        st.markdown(respuesta)
        
        # 3. Guardar respuesta del asistente
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})