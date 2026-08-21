import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# --- CSS PERSONALIZADO PARA ESTILO MINIMALISTA ---
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
        "Crear serie de acción": [],
        "Continuar proyecto de video": [],
        "Texto de relleno Ipsum": [],
        "Desarrollo Plan Inspección": [],
        "Clase de Física General": [],
        "Respuesta ejercicio 8": []
    }
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Crear serie de acción"
if "modo" not in st.session_state:
    st.session_state.modo = "💬 Chat Principal"

# --- BARRA LATERAL (Las 4 funciones una debajo de la otra) ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    st.markdown("")
    
    if st.button("✏️ Nuevo"):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.session_state.modo = "💬 Chat Principal"
        st.rerun()
        
    if st.button("🔍 Buscar"): 
        st.session_state.modo = "🔍 Buscar"
        st.rerun()

    st.markdown("---")
    
    if st.button("🖼️ Imágenes"): 
        st.session_state.modo = "🖼️ Imágenes"
    if st.button("🎬 Crear videos"): 
        st.session_state.modo = "🎬 Crear videos"

# --- ÁREA CENTRAL ---
col_head1, col_head2 = st.columns([8, 2])
with col_head1:
    st.header("⚡ ISAIAS TITAN STUDIO v3.0")
with col_head2:
    # Botón superior de búsqueda (estilo tu segunda foto)
    if st.button("🔍", help="Buscar conversaciones"):
        st.session_state.modo = "🔍 Buscar"
        st.rerun()

st.markdown(f"**Modo Activo:** `{st.session_state.modo}`")
st.markdown("---")

# --- VENTANA MODAL / POPUP DE BÚSQUEDA (Estilo tu tercera foto) ---
if st.session_state.modo == "🔍 Buscar":
    with st.container():
        st.markdown("### 🔍 Buscar en conversaciones")
        busqueda_input = st.text_input("Buscar...", placeholder="Escribe para buscar chats recientes...", label_visibility="collapsed")
        
        st.markdown("#### Chats recientes")
        for chat_id in st.session_state.chats.keys():
            # Filtro si escribe algo en la barra
            if not busqueda_input or busqueda_input.lower() in chat_id.lower():
                if st.button(f"💬  {chat_id}", key=f"modal_{chat_id}", use_container_width=True):
                    st.session_state.chat_actual = chat_id
                    st.session_state.modo = "💬 Chat Principal"
                    st.rerun()
        
        st.markdown("---")
        if st.button("❌ Cerrar buscador", use_container_width=True):
            st.session_state.modo = "💬 Chat Principal"
            st.rerun()
else:
    # Mostrar mensajes del chat actual
    for msg in st.session_state.chats[st.session_state.chat_actual]:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

    # --- ZONA DE ENTRADA INFERIOR ---
    c1, c2, c3 = st.columns([0.5, 8.5, 0.5])

    archivo_cargado = None
    with c1:
        with st.popover("➕", help="Adjuntar archivos"):
            st.markdown("### Adjuntar")
            archivo_cargado = st.file_uploader("Subir documento", type=["pdf", "docx", "pptx", "png", "jpg"], label_visibility="collapsed")

    with c2:
        placeholders = {
            "💬 Chat Principal": "Pregunta o investiga con TITAN...",
            "🖼️ Imágenes": "Describe la imagen que deseas generar...",
            "🎬 Crear videos": "Escribe el prompt o la idea para tu vídeo..."
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
        elif "video" in texto_lower or "vídeo" in texto_lower or "guion para video" in texto_lower or st.session_state.modo == "🎬 Crear videos":
            respuesta = f"🎬 **[Generador de Video TITAN]**: He procesado tu solicitud de vídeo. \n\n* **Prompt analizado:** '{prompt}'\n* **Estructura sugerida:** Escena 1 (Introducción), Escena 2 (Desarrollo), Escena 3 (Cierre)."
        elif "tarea" in texto_lower or "explícame" in texto_lower or "ayuda con" in texto_lower:
            respuesta = f"📚 **[Tutor Académico TITAN]**: Analizando tu consulta sobre *'{prompt}'*... Aquí tienes una explicación detallada paso a paso."
        else:
            respuesta = f"🤖 **[TITAN Pro]**: He procesado tu mensaje: *'{prompt}'*. ¿Qué más deseas hacer hoy?"

        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})
        with st.chat_message("assistant"):
            st.markdown(respuesta)