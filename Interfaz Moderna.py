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
    # --- PANTALLA DE BIENVEIDA COMPLETA ---
    st.markdown("<h1 style='text-align: center;'>Hola, soy TITAN✨</h1>", unsafe_allow_html=True)
    st.markdown("<p style='text-align: center; color: gray;'>El espacio de trabajo de IA todo en uno que convierte a todos en profesionales</p>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)

    # Caja de chat grande central
    prompt_nuevo = st.chat_input("Pregúntame lo que quieras o asígname una tarea.")
    
    st.markdown("<br>### 🛠️ Herramientas de IA", unsafe_allow_html=True)
    
    # Fila 1 de funciones
    f1_c1, f1_c2, f1_c3, f1_c4, f1_c5, f1_c6, f1_c7 = st.columns(7)
    with f1_c1: st.button("📁 Agente Pres.", key="h1")
    with f1_c2: st.button("📊 Hojas IA", key="h2")
    with f1_c3: st.button("🖼️ Imagen IA", key="h3")
    with f1_c4: st.button("🎬 Video IA", key="h4")
    with f1_c5: st.button("🎨 Diseño IA", key="h5")
    with f1_c6: st.button("✍️ Escritura", key="h6")
    with f1_c7: st.button("🤖 Tutor IA", key="h7")

    # Fila 2 de funciones
    f2_c1, f2_c2, f2_c3, f2_c4, f2_c5, f2_c6, f2_c7 = st.columns(7)
    with f2_c1: st.button("📄 Redactor", key="h8")
    with f2_c2: st.button("📈 Presentación", key="h9")
    with f2_c3: st.button("✒️ Humanizador", key="h10")
    with f2_c4: st.button("🔬 Investigación", key="h11")
    with f2_c5: st.button("🎙️ Podcast IA", key="h12")
    with f2_c6: st.button("📋 Currículum", key="h13")
    with f2_c7: st.button("✏️ Parafraseador", key="h14")

    st.markdown("<br><hr>", unsafe_allow_html=True)
    
    # --- SECCIÓN DE VIDEOS E IMÁGENES RECOMENDADAS ---
    st.markdown("### 🎬 Creaciones Destacadas y Videos con IA")
    
    tab_sel, tab_neg, tab_edu, tab_cre = st.tabs(["Selección", "Negocios", "Educación y académico", "Creatividad"])
    
    with tab_sel:
        v1, v2, v3 = st.columns(3)
        with v1:
            st.video("https://www.w3schools.com/html/mov_bbb.mp4")
            st.caption("🎬 Video IA: Introducción Dinámica TITAN")
        with v2:
            st.video("https://www.w3schools.com/html/mov_bbb.mp4")
            st.caption("🎬 Video IA: Animación de Producto")
        with v3:
            st.video("https://www.w3schools.com/html/mov_bbb.mp4")
            st.caption("🎬 Video IA: Explicativo 3D")

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