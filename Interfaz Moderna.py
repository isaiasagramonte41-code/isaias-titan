import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# --- CSS PERSONALIZADO ---
st.markdown("""
<style>
    [data-testid="stSidebarNav"] {display: none;}
    
    [data-testid="stSidebar"] button {
        background-color: transparent !important;
        border: none !important;
        color: inherit !important;
        text-align: left !important;
        padding: 8px 12px !important;
        border-radius: 6px !important;
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
    st.session_state.chats = {
        "Saludo inicial del asistente": [
            {"role": "assistant", "content": "¡Hola! ¿En qué puedo ayudarte hoy?"}
        ]
    }
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Saludo inicial del asistente"
if "modo" not in st.session_state:
    st.session_state.modo = "💬 Chat Principal"

# --- BARRA LATERAL ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    st.markdown("")
    
    if st.button("✏️ Nuevo proyecto"):
        nuevo_id = f"Proyecto {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.session_state.modo = "💬 Nuevo Proyecto"
        st.rerun()
        
    if st.button("📁 Mis documentos"):
        st.session_state.modo = "📁 Mis documentos"
        st.rerun()
        
    if st.button("🕒 Historial de chat"):
        st.session_state.modo = "🕒 Historial"
        st.rerun()

    st.markdown("---")
    st.markdown("**Reciente**")
    
    # Mostrar solo chats que NO estén vacíos
    for chat_id, mensajes in st.session_state.chats.items():
        if len(mensajes) > 0:
            if st.button(f"💬 {chat_id}", key=f"rec_{chat_id}"):
                st.session_state.chat_actual = chat_id
                st.session_state.modo = "💬 Chat Principal"
                st.rerun()

# --- ÁREA CENTRAL ---
if st.session_state.modo == "📁 Mis documentos":
    st.markdown("### 📁 Mis documentos guardados")
    st.info("Aquí podrás ver todos los archivos que has subido.")
    st.file_uploader("Sube un nuevo archivo", type=["pdf", "docx", "pptx", "png", "jpg"])

elif st.session_state.modo == "🕒 Historial":
    st.markdown("### 🕒 Historial de conversaciones")
    for chat_id, mensajes in st.session_state.chats.items():
        if len(mensajes) > 0:
            if st.button(f"Abrir chat: {chat_id}", key=f"hist_{chat_id}"):
                st.session_state.chat_actual = chat_id
                st.session_state.modo = "💬 Chat Principal"
                st.rerun()

elif st.session_state.modo == "💬 Nuevo Proyecto" or len(st.session_state.chats.get(st.session_state.chat_actual, [])) == 0:
    # --- PANTALLA DE BIENVENIDA MODIFICADA ---
    st.markdown("<h1 style='text-align: center;'>Hola, soy TITAN✨</h1>", unsafe_allow_html=True)
    st.markdown("<p style='text-align: center; color: gray;'>El espacio de trabajo de IA todo en uno que convierte a todos en profesionales</p>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)

    # Caja de chat grande central
    prompt_nuevo = st.chat_input("Pregúntame lo que quieras o asígname una tarea.")
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Botones de herramientas inferiores
    c1, c2, c3, c4, c5, c6, c7 = st.columns(7)
    with c1:
        if st.button("📁\nAgente Pres.", key="btn_pres"):
            st.session_state.modo = "💬 Chat Principal"
            st.rerun()
    with c2:
        if st.button("📊\nHojas IA", key="btn_hojas"):
            pass
    with c3:
        if st.button("🖼️\nImagen IA", key="btn_img"):
            pass
    with c4:
        if st.button("🎬\nVideo IA", key="btn_vid"):
            pass
    with c5:
        if st.button("🎨\nDiseño IA", key="btn_dis"):
            pass
    with c6:
        if st.button("✍️\nEscritura", key="btn_esc"):
            pass
    with c7:
        if st.button("➕\nMás", key="btn_mas"):
            pass

    if prompt_nuevo:
        st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": prompt_nuevo})
        st.session_state.modo = "💬 Chat Principal"
        st.rerun()

else:
    # Mostrar mensajes del chat actual normal
    for msg in st.session_state.chats[st.session_state.chat_actual]:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

    # Entrada inferior para chats activos
    prompt = st.chat_input("¿En qué puedo ayudarte?")

    if prompt:
        st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": prompt})
        with st.chat_message("user"):
            st.markdown(prompt)

        respuesta = f"🤖 **[TITAN AI]**: He procesado tu mensaje: *'{prompt}'*."
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})
        with st.chat_message("assistant"):
            st.markdown(respuesta)