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
if "usando_voz" not in st.session_state:
    st.session_state.usando_voz = False

# --- BARRA LATERAL ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    
    if st.button("✏️ Nueva conversación", use_container_width=True):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.rerun()

    st.markdown("")
    
    if st.button("🔍 Buscar conversaciones", use_container_width=True): 
        st.session_state.modo = "🔍 Buscar conversaciones"
    if st.button("🎓 Estudiantes", use_container_width=True): 
        st.session_state.modo = "🎓 Estudiantes"
    if st.button("🖼️ Imágenes", use_container_width=True): 
        st.session_state.modo = "🖼️ Imágenes"
    if st.button("📚 Biblioteca", use_container_width=True): 
        st.session_state.modo = "📚 Biblioteca"

    st.markdown("---")
    st.markdown("**Cuadernos**")
    if st.button("➕ Nuevo cuaderno", use_container_width=True):
        pass

    fn_recientes = st.expander("Recientes", expanded=True)
    with fn_recientes:
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

# --- PANEL DE HERRAMIENTAS Y CHAT INTEGRADO ---
# Usamos un expander limpio y elegante arriba del chat para que no rompa la estética
with st.expander("➕ Opciones avanzadas (Subir archivos, Drive, Imágenes)", expanded=False):
    subir_archivo = st.file_uploader("Sube tus documentos de clase o imágenes", type=["pdf", "docx", "pptx", "png", "jpg"])
    col_opt1, col_opt2 = st.columns(2)
    with col_opt1:
        if st.button("☁️ Añadir desde Drive", use_container_width=True):
            st.info("Conexión con Drive simulada.")
    with col_opt2:
        if st.button("🖼️ Cambiar a modo Imágenes", use_container_width=True):
            st.session_state.modo = "🖼️ Imágenes"
            st.rerun()

# Entrada de texto principal de Streamlit (el chat nativo que se ve impecable)
placeholders = {
    "🔍 Buscar conversaciones": "Pregunta o investiga con TITAN...",
    "🎓 Estudiantes": "Pregúntale al tutor académico...",
    "🖼️ Imágenes": "Describe la imagen que deseas generar...",
    "📚 Biblioteca": "Busca dentro de tus archivos..."
}

if prompt := st.chat_input(placeholders.get(st.session_state.modo, "Pregunta a TITAN...")):
    mensaje_final = prompt
    if 'subir_archivo' in locals() and subir_archivo is not None:
        mensaje_final = f"[Archivo adjunto: {subir_archivo.name}]\n\n{prompt}"

    st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": mensaje_final})
    with st.chat_message("user"):
        st.markdown(mensaje_final)

    with st.chat_message("assistant"):
        respuesta = f"🤖 [TITAN Pro]: Analizando tu solicitud..."
        st.markdown(respuesta)
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})