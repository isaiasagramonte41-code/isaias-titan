import streamlit as st

# Configuración de página
st.set_page_config(page_title="ISAIAS TITAN STUDIO", layout="wide")

# Inicialización del estado de la sesión
if "chats" not in st.session_state:
    st.session_state.chats = {"Chat Principal": []}
if "chat_actual" not in st.session_state:
    st.session_state.chat_actual = "Chat Principal"

# --- BARRA LATERAL ---
with st.sidebar:
    st.title("⚡ ISAIAS TITAN")
    
    if st.button("➕ Nuevo Chat"):
        nuevo_id = f"Chat {len(st.session_state.chats) + 1}"
        st.session_state.chats[nuevo_id] = []
        st.session_state.chat_actual = nuevo_id
        st.rerun()

    st.subheader("🔍 Buscar")
    busqueda = st.text_input("Filtrar chats...", "")
    
    st.subheader("💬 Historial")
    for chat_id in st.session_state.chats.keys():
        if busqueda.lower() in chat_id.lower():
            if st.button(chat_id, key=chat_id, use_container_width=True):
                st.session_state.chat_actual = chat_id
                st.rerun()

    st.markdown("---")
    st.button("🎓 Estudiantes")
    st.button("🖼️ Biblioteca de Imágenes")

# --- ÁREA CENTRAL ---
st.header(f"🎬 {st.session_state.chat_actual}")

# Mostrar mensajes del chat seleccionado
for msg in st.session_state.chats[st.session_state.chat_actual]:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# Entrada de mensaje
if prompt := st.chat_input("¿Qué duda tienes sobre esta historia?"):
    # 1. Guardar mensaje usuario
    st.session_state.chats[st.session_state.chat_actual].append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # 2. Generar respuesta de prueba (aquí conectaremos tu motor de IA luego)
    with st.chat_message("assistant"):
        respuesta = f"Entendido, sobre '{prompt}'. Basado en nuestra conversación anterior, esto es lo que pienso..."
        st.markdown(respuesta)
        
        # 3. Guardar respuesta asistente
        st.session_state.chats[st.session_state.chat_actual].append({"role": "assistant", "content": respuesta})