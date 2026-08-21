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

# --- BARRA LATERAL (Estilo Minimalista Gemini) ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    
    # Botón minimalista de nueva conversación
    if st.button("✏️ Nueva conversación", use_container_width=True):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.rerun()

    st.markdown("")
    
    # Menú de navegación plano estilo Gemini
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

# --- ZONA DE ENTRADA INFERIOR (Estilo Gemini con Popover y Micrófono) ---
col_input1, col_input2, col_input3 = st.columns([0.8, 8.4, 0.8])

with col_input1:
    with st.popover("➕", help="Opciones de adjunto y creación"):
        st.markdown("### Opciones de Entrada")
        subir_archivo = st.file_uploader("📁 Subir archivos", type=["pdf", "docx", "pptx", "png", "jpg"])
        if st.button("☁️ Añadir desde Drive"):
            st.info("Conexión con Drive simulada.")
        if st.button("🖼️ Crear imagen"):
            st.session_state.modo = "🖼️ Imágenes"
            st.rerun()
        if st.button("🎵 Crear música"):
            st.toast("Módulo de música en desarrollo...")
        if st.button("✨ Aprendizaje guiado"):
            st.session_state.modo = "🎓 Estudiantes"
            st.rerun()

with col_input2:
    placeholders = {
        "🔍 Buscar conversaciones": "Pregunta o investiga con TITAN...",
        "🎓 Estudiantes": "Pregúntale al tutor académico...",
        "🖼️ Imágenes": "Describe la imagen que deseas generar...",
        "📚 Biblioteca": "Busca dentro de tus archivos..."
    }
    prompt = st.chat_input(placeholders.get(st.session_state.modo, "Pregunta a TITAN..."))

with col_input3:
    if st.button("🎙️", help="Dictar por voz"):
        st.session_state.usando_voz = not st.session_state.usando_voz

if st.session_state.usando_voz:
    st.info("🎙️ [Micrófono Activo]: Escuchando y transcribiendo...")

# Procesamiento del mensaje
if prompt:
    mensaje_final = prompt
    if 'subir_archivo' in locals() and subir_archivo is not None:
        mensaje_final = f"[Archivo adjunto: {subir_archivo.name}]\n\n{prompt}"
        st.success(f"📎 Archivo listo: {subir_archivo.name}")

    st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": mensaje_final})
    with st.chat_message("user"):
        st.markdown(mensaje_final)

    with st.chat_message("assistant"):
        respuesta = f"🤖 [TITAN Pro]: Analizando tu solicitud..."
        st.markdown(respuesta)
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})