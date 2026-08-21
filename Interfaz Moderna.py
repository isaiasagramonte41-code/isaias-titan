import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# Inicialización de estado
if "chats" not in st.session_state:
    st.session_state.chats = {
        "Ciudad futurista de noche": [],
        "Astronauta en Marte": [],
        "Causas Revolución Francesa": []
    }
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Ciudad futurista de noche"
if "modo" not in st.session_state:
    st.session_state.modo = "🔍 Buscar conversaciones"

# --- BARRA LATERAL ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    if st.button("✏️ Nueva conversación", use_container_width=True):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.rerun()

    st.markdown("")
    if st.button("🔍 Buscar conversaciones", use_container_width=True): st.session_state.modo = "🔍 Buscar conversaciones"
    if st.button("🎓 Estudiantes", use_container_width=True): st.session_state.modo = "🎓 Estudiantes"
    if st.button("🖼️ Imágenes", use_container_width=True): st.session_state.modo = "🖼️ Imágenes"
    if st.button("📚 Biblioteca", use_container_width=True): st.session_state.modo = "📚 Biblioteca"

    st.markdown("---")
    st.markdown("**Cuadernos**")
    if st.button("➕ Nuevo cuaderno", use_container_width=True): pass
    
    st.markdown("---")
    st.markdown("**Recientes**")
    for chat_id in st.session_state.chats.keys():
        if st.button(chat_id, key=f"hist_{chat_id}", use_container_width=True):
            st.session_state.chat_actual = chat_id
            st.rerun()

# --- ÁREA CENTRAL ---
st.header("⚡ ISAIAS TITAN STUDIO v3.0")
st.markdown(f"**Modo Activo:** `{st.session_state.modo}`")
st.markdown("---")

for msg in st.session_state.chats[st.session_state.chat_actual]:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# --- ZONA DE ENTRADA INFERIOR (Fila limpia) ---
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
    # 1. Guardar mensaje del usuario
    mensaje_usuario = prompt
    if archivo_cargado:
        mensaje_usuario = f"[Archivo adjunto: {archivo_cargado.name}]\n\n{prompt}"
    
    st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": mensaje_usuario})
    with st.chat_message("user"):
        st.markdown(mensaje_usuario)

    # 2. Generar respuesta inteligente de TITAN
    texto_lower = prompt.lower()
    
    if "creador" in texto_lower or "quién te creó" in texto_lower or "quien te hizo" in texto_lower:
        respuesta = "😎 Mi creador y mente maestra es **Isaías**. Él me diseñó y programó para convertirme en el mejor asistente de inteligencia artificial."
    
    elif "video" in texto_lower or "vídeo" in texto_lower or "guion para video" in texto_lower:
        respuesta = f"🎬 **[Generador de Video TITAN]**: He procesado tu solicitud para video basada en tu texto. \n\n* **Idea / Prompt analizado:** '{prompt}'\n* **Estructura sugerida:** Escena 1 (Introducción atractiva), Escena 2 (Desarrollo del contenido), Escena 3 (Cierre épico).\n\n*(Módulo listo para conectar con API de generación de video en la siguiente fase)*."
    
    elif "tarea" in texto_lower or "explícame" in texto_lower or "ayuda con" in texto_lower:
        respuesta = f"📚 **[Tutor Académico TITAN]**: Entendido con tu tarea. Analizando tu consulta sobre *'{prompt}'*... \n\nAquí tienes una explicación detallada y paso a paso para que domines el tema con éxito. ¿Deseas que profundice en algún punto en específico?"
    
    else:
        respuesta = f"🤖 **[TITAN Pro]**: He procesado tu mensaje: *'{prompt}'*. Como inteligencia artificial de vanguardia, estoy aquí para ayudarte a investigar, redactar y estructurar tus ideas. ¿Qué más deseas hacer hoy?"

    st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})
    with st.chat_message("assistant"):
        st.markdown(respuesta)