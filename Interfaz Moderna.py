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
    st.session_state.chats = {}
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = None
if "modo" not in st.session_state:
    st.session_state.modo = "💬 Nuevo Proyecto"

# --- BARRA LATERAL ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    st.markdown("")
    
    if st.button("✏️ Nuevo proyecto"):
        st.session_state.chat_actual = None
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
    
    # Listar chats recientes con menú flotante limpio (estilo 3 puntos)
    for chat_id, mensajes in list(st.session_state.chats.items()):
        if len(mensajes) > 0:
            c1, c2 = st.columns([0.8, 0.2])
            with c1:
                if st.button(f"💬 {chat_id}", key=f"rec_{chat_id}"):
                    st.session_state.chat_actual = chat_id
                    st.session_state.modo = "💬 Chat Activo"
                    st.rerun()
            with c2:
                # Menú flotante (popover) de tres puntos para opciones ocultas
                with st.popover("⋮", help="Opciones"):
                    if st.button("🗑️ Eliminar chat", key=f"del_pop_{chat_id}"):
                        del st.session_state.chats[chat_id]
                        if st.session_state.chat_actual == chat_id:
                            st.session_state.chat_actual = None
                            st.session_state.modo = "💬 Nuevo Proyecto"
                        st.rerun()

# --- ÁREA CENTRAL ---
if st.session_state.modo == "📁 Mis documentos":
    st.markdown("### 📁 Mis documentos guardados")
    st.info("Aquí podrás ver todos los archivos que has subido.")
    st.file_uploader("Sube un nuevo archivo", type=["pdf", "docx", "pptx", "png", "jpg"])

elif st.session_state.modo == "🕒 Historial":
    st.markdown("### 🕒 Historial de conversaciones")
    for chat_id, mensajes in list(st.session_state.chats.items()):
        if len(mensajes) > 0:
            col_h1, col_h2 = st.columns([0.9, 0.1])
            with col_h1:
                if st.button(f"Abrir chat: {chat_id}", key=f"hist_{chat_id}"):
                    st.session_state.chat_actual = chat_id
                    st.session_state.modo = "💬 Chat Activo"
                    st.rerun()
            with col_h2:
                with st.popover("⋮"):
                    if st.button("🗑️ Eliminar", key=f"del_hist_pop_{chat_id}"):
                        del st.session_state.chats[chat_id]
                        if st.session_state.chat_actual == chat_id:
                            st.session_state.chat_actual = None
                            st.session_state.modo = "💬 Nuevo Proyecto"
                        st.rerun()

elif st.session_state.chat_actual is None or st.session_state.modo == "💬 Nuevo Proyecto":
    # --- PANTALLA DE BIENVENIDA ---
    st.markdown("<br><br>", unsafe_allow_html=True)
    st.markdown("<h1 style='text-align: center;'>Hola, soy TITAN✨</h1>", unsafe_allow_html=True)
    st.markdown("<p style='text-align: center; color: gray;'>El espacio de trabajo de IA todo en uno que convierte a todos en profesionales</p>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)

    prompt_inicial = st.chat_input("Pregúntame lo que quieras o asígname una tarea.")
    
    st.markdown("<br>", unsafe_allow_html=True)

    # Las 14 herramientas
    st.markdown("##### 🛠️ Herramientas disponibles", unsafe_allow_html=True)
    f1_c1, f1_c2, f1_c3, f1_c4, f1_c5, f1_c6, f1_c7 = st.columns(7)
    with f1_c1: st.button("📁 Agente Pres.", key="h1")
    with f1_c2: st.button("📊 Hojas IA", key="h2")
    with f1_c3: st.button("🖼️ Imagen IA", key="h3")
    with f1_c4: st.button("🎬 Video IA", key="h4")
    with f1_c5: st.button("🎨 Diseño IA", key="h5")
    with f1_c6: st.button("✍️ Escritura", key="h6")
    with f1_c7: st.button("🤖 Tutor IA", key="h7")

    f2_c1, f2_c2, f2_c3, f2_c4, f2_c5, f2_c6, f2_c7 = st.columns(7)
    with f2_c1: st.button("📄 Redactor", key="h8")
    with f2_c2: st.button("📈 Presentación", key="h9")
    with f2_c3: st.button("✒️ Humanizador", key="h10")
    with f2_c4: st.button("🔬 Investigación", key="h11")
    with f2_c5: st.button("🎙️ Podcast IA", key="h12")
    with f2_c6: st.button("📋 Currículum", key="h13")
    with f2_c7: st.button("✏️ Parafraseador", key="h14")

    st.markdown("<br><hr>", unsafe_allow_html=True)
    
    # Galería de videos IA
    st.markdown("### 🎬 Videos con IA Destacados")
    v1, v2, v3 = st.columns(3)
    with v1:
        st.video("https://www.w3schools.com/html/mov_bbb.mp4")
        st.caption("🎬 Introducción Dinámica TITAN")
    with v2:
        st.video("https://www.w3schools.com/html/mov_bbb.mp4")
        st.caption("🎬 Animación Publicitaria IA")
    with v3:
        st.video("https://www.w3schools.com/html/mov_bbb.mp4")
        st.caption("🎬 Explicador 3D con IA")

    if prompt_inicial:
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = [
            {"role": "user", "content": prompt_inicial},
            {"role": "assistant", "content": f"¡Hola! 👋 ¿En qué puedo ayudarte hoy con respecto a: *'{prompt_inicial}'*?"}
        ]
        st.session_state.chat_actual = nuevo_id
        st.session_state.modo = "💬 Chat Activo"
        st.rerun()

else:
    # --- VISTA DE CONVERSACIÓN ACTIVA ---
    col_t1, col_t2 = st.columns([8, 2])
    with col_t1:
        st.markdown(f"### {st.session_state.chat_actual}")
    with col_t2:
        # Menú de tres puntos también arriba en el chat activo para borrar
        with st.popover("⋮ Opciones", use_container_width=True):
            if st.button("🗑️ Eliminar este chat", key="del_chat_activo"):
                del st.session_state.chats[st.session_state.chat_actual]
                st.session_state.chat_actual = None
                st.session_state.modo = "💬 Nuevo Proyecto"
                st.rerun()

    st.markdown("---")

    # Mostrar mensajes previos
    for msg in st.session_state.chats[st.session_state.chat_actual]:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

    # Tarjetas de sugerencia rápida
    st.markdown("<br>", unsafe_allow_html=True)
    if st.button("📄 Ayúdame a redactar un currículum profesional"):
        st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": "Ayúdame a redactar un currículum profesional"})
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": "📄 **[Currículum AI]**: Perfecto. ¿Para qué puesto de trabajo deseas postularte y cuáles son tus habilidades principales?"})
        st.rerun()
        
    if st.button("📊 Crea una presentación sobre un tema de mi interés"):
        st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": "Crea una presentación sobre un tema de mi interés"})
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": "📊 **[Presentación AI]**: ¡Claro que sí! Dime de qué tema trata y cuántas diapositivas necesitas."})
        st.rerun()

    # Caja de texto fija inferior
    prompt_continuo = st.chat_input("¿En qué puedo ayudarte?")
    
    if prompt_continuo:
        st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": prompt_continuo})
        respuesta_ia = f"🤖 **[TITAN AI]**: He procesado tu mensaje: *'{prompt_continuo}'*. ¿Qué más hacemos?"
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta_ia})
        st.rerun()