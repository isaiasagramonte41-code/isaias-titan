import streamlit as st
from motor_ia import optimizar_prompt_con_groq, generar_video_runway, generar_voz_elevenlabs

# Configuración de la página
st.set_page_config(
    page_title="ISAIAS TITAN STUDIO",
    page_icon="⚡",
    layout="wide"
)

# Estilo visual personalizado para imitar la interfaz moderna oscura de chat
st.markdown("""
    <style>
    .main {
        background-color: #0e1117;
    }
    .stChatInputContainer {
        padding-bottom: 20px;
    }
    </style>
""", unsafe_allow_html=True)

# --- BARRA LATERAL (Estilo Panel Izquierdo) ---
with st.sidebar:
    st.markdown("### ⚡ ISAIAS TITAN")
    st.markdown("---")
    
    if st.button("➕ Nuevo Chat", use_container_width=True):
        st.session_state.messages = []
        st.rerun()
        
    st.markdown("#### 🛠️ Modos de Creación")
    modo_seleccionado = st.radio(
        "Herramienta activa:",
        ["🎬 Texto a Video (Runway)", "🎙️ Locución (ElevenLabs)", "🧠 Optimizar Prompt (Groq)"],
        label_visibility="collapsed"
    )
    
    st.markdown("---")
    st.markdown("#### 📂 Historial de Sesión")
    st.caption("La Serie Épica: Poder y Traición...")
    
    st.markdown("---")
    st.info("💡 **Consejo:** Escribe tu idea abajo y deja que el Titán la convierta en multimedia.")

# --- ÁREA PRINCIPAL (Estilo Chat Fluido) ---
st.title("🎬 ISAIAS TITAN STUDIO v3.0")
st.caption(f"Modo Activo: {modo_seleccionado}")

# Inicializar el historial del chat en la sesión
if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "¡Hola, Isaías! Soy tu director de IA. ¿Qué historia, escena o proyecto multimedia crearemos hoy?"}
    ]

# Mostrar el historial de mensajes en pantalla
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# --- CAJA DE ENTRADA DE TEXTO (Abajo, estilo chat moderno) ---
if prompt_usuario := st.chat_input("Escribe tu idea o prompt aquí..."):
    # Guardar mensaje del usuario
    st.session_state.messages.append({"role": "user", "content": prompt_usuario})
    with st.chat_message("user"):
        st.markdown(prompt_usuario)

    # Generar respuesta de la IA según el modo elegido
    with st.chat_message("assistant"):
        with st.spinner("ISAIAS TITAN trabajando en tu solicitud..."):
            try:
                if "Texto a Video" in modo_seleccionado:
                    prompt_opt = optimizar_prompt_con_groq(prompt_usuario)
                    st.markdown(f"**Prompt optimizado:** `{prompt_opt}`")
                    ruta_video = generar_video_runway(prompt_opt)
                    st.success("¡Video generado con éxito!")
                    st.video(ruta_video)
                    respuesta_final = f"Aquí tienes tu escena de video basada en: *{prompt_usuario}*"
                
                elif "Locución" in modo_seleccionado:
                    ruta_audio = generar_voz_elevenlabs(prompt_usuario)
                    st.success("¡Locución generada con éxito!")
                    st.audio(ruta_audio)
                    respuesta_final = f"Aquí tienes el audio generado para tu texto."
                
                else:  # Solo optimizar con Groq
                    prompt_opt = optimizar_prompt_con_groq(prompt_usuario)
                    st.markdown("### Prompt Cinematográfico:")
                    st.code(prompt_opt, language="text")
                    respuesta_final = "Prompt optimizado y listo para producción."

                st.session_state.messages.append({"role": "assistant", "content": respuesta_final})
            
            except Exception as e:
                error_msg = f"Ocurrió un error al procesar: {str(e)}"
                st.error(error_msg)
                st.session_state.messages.append({"role": "assistant", "content": error_msg})