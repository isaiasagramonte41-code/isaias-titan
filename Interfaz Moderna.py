import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# --- CSS PERSONALIZADO PARA ESTILO GEMINI EN LA BARRA LATERAL ---
st.markdown("""
<style>
    /* Ocultar elementos predeterminados de Streamlit que ocupan espacio extra */
    [data-testid="stSidebarNav"] {display: none;}
    
    /* Estilizar los botones de la barra lateral para que parezcan texto plano minimalista */
    [data-testid="stSidebar"] button {
        background-color: transparent !important;
        border: none !important;
        color: inherit !important;
        text-align: left !important;
        padding: 6px 10px !important;
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
    st.session_state.chats = {"Nueva conversación": []}
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Nueva conversación"
if "modo" not in st.session_state:
    st.session_state.modo = "💬 Chat Principal"

# --- BARRA LATERAL (Estilo Minimalista Gemini) ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    st.markdown("")
    
    # Fila superior conjunta: Nueva conversación y Buscar conversaciones lado a lado
    col_sb1, col_sb2 = st.columns(2)
    with col_sb1:
        if st.button("✏️ Nuevo", help="Nueva conversación"):
            nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
            st.session_state.chats[nuevo_id] = []
            st.session_state.chat_actual = nuevo_id
            st.session_state.modo = "💬 Chat Principal"
            st.rerun()
    with col_sb2:
        if st.button("🔍 Buscar", help="Buscar en conversaciones"): 
            st.session_state.modo = "🔍 Buscar"

    st.markdown("---")
    
    # Opciones de navegación principales limpias
    if st.button("🖼️ Imágenes"): 
        st.session_state.modo = "🖼️ Imágenes"
    if st.button("🎬 Crear videos"): 
        st.session_state.modo = "🎬 Crear videos"

# --- ÁREA CENTRAL ---
st.header("⚡ ISAIAS TITAN STUDIO v3.0")
st.markdown(f"**Modo Activo:** `{st.session_state.modo}`")
st.markdown("---")

# --- SI EL MODO ES BUSCAR, MOSTRAMOS SU BARRA DE ESCRITURA ESPECIAL ---
if st.session_state.modo == "🔍 Buscar":
    st.markdown("### 🔍 Búsqueda en el sistema")
    query_busqueda = st.text_input("Escribe palabras clave para buscar en tus chats o temas...", placeholder="Ej: tarea, video, historia...")
    
    if query_busqueda:
        st.info(f"🔎 Resultados encontrados para: **{query_busqueda}**")
        # Mostramos coincidencias simuladas en los chats actuales
        encontrado = False
        for nombre_chat, mensajes in st.session_state.chats.items():
            for m in mensajes:
                if query_busqueda.lower() in m["content"].lower():
                    st.success(f"Encontrado en el chat **{nombre_chat}**: {m['content'][:80]}...")
                    encontrado = True
        if not encontrado:
            st.warning("No se encontraron coincidencias exactas en los mensajes actuales.")
else:
    # Mostrar mensajes del chat actual normal
    for msg in st.session_state.chats[st.session_state.chat_actual]:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

    # --- ZONA DE ENTRADA INFERIOR (Fila limpia con el signo de más y el micrófono) ---
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
            respuesta = f"🎬 **[Generador de Video TITAN]**: He procesado tu solicitud para vídeo basada en tu texto. \n\n* **Prompt analizado:** '{prompt}'\n* **Estructura sugerida:** Escena 1 (Introducción), Escena 2 (Desarrollo), Escena 3 (Cierre épico)."
        elif "tarea" in texto_lower or "explícame" in texto_lower or "ayuda con" in texto_lower:
            respuesta = f"📚 **[Tutor Académico TITAN]**: Analizando tu consulta sobre *'{prompt}'*... Aquí tienes una explicación detallada paso a paso."
        else:
            respuesta = f"🤖 **[TITAN Pro]**: He procesado tu mensaje: *'{prompt}'*. ¿Qué más deseas hacer hoy?"

        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})
        with st.chat_message("assistant"):
            st.markdown(respuesta)