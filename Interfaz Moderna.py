import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# --- CSS PERSONALIZADO PARA ESTILO GEMINI EN LA BARRA LATERAL ---
st.markdown("""
<style>
    /* Ocultar elementos predeterminados de Streamlit que ocupan espacio extra */
    [data-testid="stSidebarNav"] {display: none;}
    
    /* Estilizar los botones de la barra lateral para que parezcan texto plano minimalista */
    [data-testid="stSidebar"] button {
        background-color: transparent !important;
        border: none !important;
        color: inherit !important;
        text-align: left !important;
        padding: 8px 12px !important;
        border-radius: 8px !important;
        width: 100% !important;
        font-weight: 400 !important;
    }
    [data-testid="stSidebar"] button:hover {
        background-color: rgba(150, 150, 150, 0.15) !important;
    }
</style>
""", unsafe_allow_html=True)

# Inicialización de estado
if "chats" not in st.session_state:
    st.session_state.chats = {"Nueva conversación": []}
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Nueva conversación"
if "modo" not in st.session_state:
    st.session_state.modo = "🔍 Buscar conversaciones"

# --- BARRA LATERAL (Estilo Minimalista Gemini) ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    
    if st.button("✏️ Nueva conversación"):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.rerun()

    st.markdown("---")
    
    # Opciones de navegación con estilo plano
    if st.button("🔍 Buscar conversaciones"): 
        st.session_state.modo = "🔍 Buscar conversaciones"
    if st.button("🎓 Estudiantes"): 
        st.session_state.modo = "🎓 Estudiantes"
    if st.button("🖼️ Imágenes"): 
        st.session_state.modo = "🖼️ Imágenes"
    if st.button("📚 Biblioteca"): 
        st.session_state.modo = "📚 Biblioteca"

    st.markdown("---")
    st.markdown("**Cuadernos**")
    if st.button("➕ Nuevo cuaderno"): 
        pass

# --- ÁREA CENTRAL ---
st.header("⚡ ISAIAS TITAN STUDIO v3.0")
st.markdown(f"**Modo Activo:** `{st.session_state.modo}`")
st.markdown("---")

# Mostrar mensajes del chat actual
for msg in st.session_state.chats[st.session_state.chat_actual]:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# --- ZONA DE ENTRADA INFERIOR (Fila limpia con el signo de más y el micrófono) ---
c1, c2, c3 = st.columns([0.5, 8.5, 0.5])

archivo_cargado = None
with c1:
    with st.popover("➕", help="Adjuntar archivos"):
        st.markdown("### Adjuntar")
        archivo_cargado = st.file_uploader("Subir documento", type=["pdf", "docx", "pptx", "png", "jpg"], label_visibility="collapsed")

with c2:
    placeholders = {
        "🔍 Buscar conversaciones": "Pregunta o investiga con TITAN...",
        "🎓 Estudiantes": "Pregúntale al tutor académico sobre tu tarea...",
        "🖼️ Imágenes": "Describe la imagen o el vídeo que deseas...",
        "📚 Biblioteca": "Busca dentro de tus archivos..."
    }
    prompt = st.chat_input(placeholders.get(st.session_state.modo, "Pregunta a TITAN..."))

with c3:
    st.button("🎙️", help="Dictar voz")

# --- LÓGICA DE INTELIGENCIA DE TITAN ---
if prompt:
    mensaje_usuario = prompt
    if archivo_cargado:
        mensaje_usuario = f"[Archivo adjunto: {archivo_cargado.name}]\n\n{prompt}"
    
    st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": mensaje_usuario})
    with st.chat_message("user"):
        st.markdown(mensaje_usuario)

    texto_lower = prompt.lower()
    
    if "creador" in texto_lower or "quién te creó" in texto_lower or "quien te hizo" in texto_lower:
        respuesta = "😎 Mi creador y mente maestra es **Isaías**. Él me diseñó y programó para convertirme en el mejor asistente de inteligencia artificial."
    elif "video" in texto_lower or "vídeo" in texto_lower or "guion para video" in texto_lower:
        respuesta = f"🎬 **[Generador de Video TITAN]**: He procesado tu solicitud de video basada en tu texto. \n\n* **Prompt analizado:** '{prompt}'\n* **Estructura sugerida:** Escena 1 (Introducción), Escena 2 (Desarrollo), Escena 3 (Cierre)."
    elif "tarea" in texto_lower or "explícame" in texto_lower or "ayuda con" in texto_lower:
        respuesta = f"📚 **[Tutor Académico TITAN]**: Analizando tu consulta sobre *'{prompt}'*... Aquí tienes una explicación detallada paso a paso."
    else:
        respuesta = f"🤖 **[TITAN Pro]**: He procesado tu mensaje: *'{prompt}'*. ¿Qué más deseas hacer hoy?"

    st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})
    with st.chat_message("assistant"):
        respuesta_container = st.empty()
        respuesta_container.markdown(respuesta)