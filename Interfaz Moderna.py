import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# Inicialización de estado
if "chats" not in st.session_state:
    st.session_state.chats = {"Chat Principal": []}
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Chat Principal"
if "modo" not in st.session_state:
    st.session_state.modo = "🔍 Buscar"

# --- BARRA LATERAL ---
with st.sidebar:
    st.title("⚡ ISAIAS TITAN")
    
    # 1. Botón de Nuevo Chat
    if st.button("➕ Nuevo Chat", use_container_width=True):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.rerun()

    st.markdown("---")
    
    # 2. Nuevos botones de navegación rápida debajo de Nuevo Chat
    st.subheader("🧭 Navegación")
    
    if st.button("🔍 Buscar", use_container_width=True):
        st.session_state.modo = "🔍 Buscar"
        st.rerun()
        
    if st.button("🎓 Estudiantes", use_container_width=True):
        st.session_state.modo = "🎓 Estudiantes"
        st.rerun()
        
    if st.button("🖼️ Imagen", use_container_width=True):
        st.session_state.modo = "🖼️ Imagen"
        st.rerun()
        
    if st.button("📚 Biblioteca", use_container_width=True):
        st.session_state.modo = "📚 Biblioteca"
        st.rerun()

    st.markdown("---")
    st.subheader("📂 Historial de Sesión")
    for chat_id in st.session_state.chats.keys():
        if st.button(chat_id, key=chat_id, use_container_width=True):
            st.session_state.chat_actual = chat_id
            st.rerun()

# --- ÁREA CENTRAL ---
st.header(f"🚀 ISAIAS TITAN STUDIO v3.0")
st.markdown(f"**Modo Activo:** {st.session_state.modo}")
st.markdown("---")

# Mostrar mensajes del chat actual
for msg in st.session_state.chats[st.session_state.chat_actual]:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# Entrada de mensaje según el modo activo
placeholder_text = {
    "🔍 Buscar": "¿Qué deseas investigar o buscar hoy?",
    "🎓 Estudiantes": "Pregúntale algo al tutor académico de estudiantes...",
    "🖼️ Imagen": "Describe la imagen épica que deseas crear...",
    "📚 Biblioteca": "Busca recursos o documentos en tu biblioteca..."
}.get(st.session_state.modo, "Escribe tu idea...")

if prompt := st.chat_input(placeholder_text):
    # Guardar mensaje del usuario
    st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Respuesta simulada según el modo seleccionado
    with st.chat_message("assistant"):
        modo = st.session_state.modo
        
        if "Buscar" in modo:
            respuesta = f"🔍 [Búsqueda del Titán]: Investigando sobre '{prompt}'..."
        elif "Estudiantes" in modo:
            respuesta = f"🎓 [Módulo Estudiantes]: Analizando consulta educativa para: '{prompt}'..."
        elif "Imagen" in modo:
            respuesta = f"🖼️ [Generador de Imágenes]: Creando visualización de: '{prompt}'..."
        elif "Biblioteca" in modo:
            respuesta = f"📚 [Biblioteca]: Buscando registros relacionados con: '{prompt}'..."
        
        st.markdown(respuesta)
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})