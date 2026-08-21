import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# --- CSS PERSONALIZADO PARA ESTILO PREMIUM ---
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
            {"role": "assistant", "content": """¡Hola! 👋 ¿En qué puedo ayudarte hoy? Puedo asistirte con muchas cosas, como:
* 📊 **Crear presentaciones** (PPT)
* 📄 **Generar currículums** o documentos
* 🔍 **Investigar** temas en profundidad
* ✍️ **Escribir artículos** o contenido
* 📈 **Visualizar datos** o crear gráficos
* 🖼️ **Generar o editar imágenes**
* 🎬 **Crear vídeos**
* 📁 **Convertir archivos** (PDF, Word, Excel, etc.)
* 🎓 **Apoyo académico** (mapas mentales, flashcards, cuestionarios)

Cuéntame qué necesitas y lo hacemos. 😊"""}
        ]
    }
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Saludo inicial del asistente"
if "modo" not in st.session_state:
    st.session_state.modo = "💬 Chat Principal"

# --- BARRA LATERAL ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN AI")
    st.markdown("")
    
    if st.button("✏️ Nuevo proyecto"):
        nuevo_id = f"Proyecto {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.session_state.modo = "💬 Chat Principal"
        st.rerun()
        
    if st.button("📁 Mis documentos"):
        st.session_state.modo = "📁 Mis documentos"
        st.rerun()
        
    if st.button("🕒 Historial de chat"):
        st.session_state.modo = "🕒 Historial"
        st.rerun()

    st.markdown("---")
    st.markdown("**Recientes**")
    
    for chat_id in st.session_state.chats.keys():
        if st.button(f"💬 {chat_id}", key=f"rec_{chat_id}"):
            st.session_state.chat_actual = chat_id
            st.session_state.modo = "💬 Chat Principal"
            st.rerun()

    st.markdown("---")
    # Perfil de usuario abajo
    st.markdown("👤 **isaiasagramonte4...**")

# --- ÁREA CENTRAL ---
st.markdown(f"### {st.session_state.chat_actual}")
st.markdown("---")

if st.session_state.modo == "📁 Mis documentos":
    st.markdown("### 📁 Mis documentos guardados")
    st.info("Aquí podrás ver todos los archivos que has subido a tus proyectos.")
    st.file_uploader("Sube un nuevo archivo", type=["pdf", "docx", "pptx", "png", "jpg"])

elif st.session_state.modo == "🕒 Historial":
    st.markdown("### 🕒 Historial de conversaciones")
    for chat_id in st.session_state.chats.keys():
        if st.button(f"Abrir chat: {chat_id}", key=f"hist_{chat_id}"):
            st.session_state.chat_actual = chat_id
            st.session_state.modo = "💬 Chat Principal"
            st.rerun()

else:
    # Mostrar mensajes del chat actual
    for msg in st.session_state.chats[st.session_state.chat_actual]:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

    # --- ZONA DE ENTRADA INFERIOR (Estilo Captura) ---
    c_clip, c_input = st.columns([0.6, 9.4])

    archivo_cargado = None
    with c_clip:
        with st.popover("📎", help="Adjuntar archivos"):
            st.markdown("### Adjuntar archivo")
            archivo_cargado = st.file_uploader("Subir documento", type=["pdf", "docx", "pptx", "png", "jpg"], label_visibility="collapsed")

    with c_input:
        prompt = st.chat_input("¿En qué puedo ayudarte?")

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
            respuesta = "😎 Mi creador y mente maestra es **Isaías**. Él me diseñó y programó."
        elif "presentación" in texto_lower or "ppt" in texto_lower:
            respuesta = "📊 **[Módulo de Presentaciones]**: He estructurado tu contenido en diapositivas profesionales listas para exportar a PowerPoint."
        elif "currículum" in texto_lower or "cv" in texto_lower:
            respuesta = "📄 **[Generador de Currículums]**: He redactado un formato profesional y moderno adaptado a tus requerimientos."
        elif "video" in texto_lower or "vídeo" in texto_lower:
            respuesta = "🎬 **[Creador de Vídeos]**: Guion y estructura de vídeo generado con éxito a partir de tu prompt."
        elif "imagen" in texto_lower or "foto" in texto_lower:
            respuesta = "🖼️ **[Generador de Imágenes]**: Procesando la descripción visual para generar tu imagen..."
        else:
            respuesta = f"🤖 **[TITAN AI]**: He procesado tu solicitud: *'{prompt}'*. ¿Qué más te gustaría que hagamos hoy?"

        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})
        with st.chat_message("assistant"):
            st.markdown(respuesta)