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
    st.session_state.modo = "🔍 Buscar"
if "usando_voz" not in st.session_state:
    st.session_state.usando_voz = False

# --- BARRA LATERAL ---
with st.sidebar:
    st.title("⚡ ISAIAS TITAN")
    
    if st.button("➕ Nueva conversación", use_container_width=True):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.rerun()

    st.markdown("---")
    st.markdown("**NAVEGACIÓN**")
    
    if st.button("🔍 Buscar conversaciones", use_container_width=True): 
        st.session_state.modo = "🔍 Buscar"
    if st.button("🎓 Estudiantes", use_container_width=True): 
        st.session_state.modo = "🎓 Estudiantes"
    if st.button("🖼️ Imágenes", use_container_width=True): 
        st.session_state.modo = "🖼️ Imágenes"
    if st.button("📚 Biblioteca", use_container_width=True): 
        st.session_state.modo = "📚 Biblioteca"

    st.markdown("---")
    st.markdown("**CUADERNOS**")
    if st.button("➕ Nuevo cuaderno", use_container_width=True):
        pass

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

# Mostrar mensajes del chat actual
for msg in st.session_state.chats[st.session_state.chat_actual]:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# --- BARRA DE ACCESOS DIRECTOS AL LADO DEL CHAT ---
# Creamos una fila horizontal compacta justo antes de la entrada del chat
col_btn1, col_btn2, col_vacía = st.columns([1.2, 1, 4])

with col_btn1:
    # Usamos un file_uploader minimalista para simular el botón de adjuntar
    archivo_subido = st.file_uploader(
        "➕ Adjuntar", 
        type=["pdf", "docx", "pptx", "png", "jpg", "jpeg", "txt"],
        label_visibility="collapsed"
    )

with col_btn2:
    if st.button("🎙️ Dictar", use_container_width=True):
        st.session_state.usando_voz = not st.session_state.usando_voz

if st.session_state.usando_voz:
    st.info("🎙️ [Micrófono Activo]: Escuchando y transcribiendo...")

if archivo_subido is not None:
    st.success(f"📎 Archivo listo: **{archivo_subido.name}**")

# Entrada de texto del chat (Abajo del todo)
placeholders = {
    "🔍 Buscar": "¿Qué deseas buscar o investigar hoy?",
    "🎓 Estudiantes": "Pregúntale al tutor académico...",
    "🖼️ Imágenes": "Describe la imagen que deseas generar...",
    "📚 Biblioteca": "Busca dentro de tus archivos y documentos..."
}

if prompt := st.chat_input(placeholders.get(st.session_state.modo, "Pregunta a TITAN...")):
    mensaje_final = prompt
    if 'archivo_subido' in locals() and archivo_subido is not None:
        mensaje_final = f"[Archivo adjunto: {archivo_subido.name}] \n\n {prompt}"

    st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": mensaje_final})
    with st.chat_message("user"):
        st.markdown(mensaje_final)

    with st.chat_message("assistant"):
        respuesta = f"🤖 [TITAN Pro]: Procesando tu solicitud..."
        st.markdown(respuesta)
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})