import streamlit as st
from motor_ia import optimizar_prompt_con_groq, generar_video_runway, generar_voz_elevenlabs

# Configuración de la página web
st.set_page_config(
    page_title="ISAIAS TITAN STUDIO v3.0",
    page_icon="⚡",
    layout="wide"
)

# --- Barra Lateral (Sidebar) ---
st.sidebar.markdown("# ⚡ TITAN")
st.sidebar.markdown("---")

modo = st.sidebar.radio("Selecciona el Modo:", ["Video", "Imagen", "Audio"])

st.sidebar.markdown("---")
st.sidebar.info("ISAIAS TITAN STUDIO - Potenciado por IA para cine y multimedia.")

# --- Área Principal ---
st.title("🎬 ISAIAS TITAN STUDIO v3.0")
st.subheader(f"Modo actual: {modo}")

# Caja de texto para la idea del usuario
idea_usuario = st.text_area(
    "Describe tu escena cinematográfica aquí...", 
    placeholder="Ej: Un astronauta solitario mirando lunas gemelas en un planeta alienígena..."
)

# Botón de ejecución
if st.button("🚀 GENERAR CONTENIDO", type="primary", use_container_width=True):
    if not idea_usuario.strip():
        st.warning("Por favor, escribe una idea o descripción antes de generar.")
    else:
        with st.status("ISAIAS TITAN procesando...", expanded=True) as status:
            st.write("Analizando y optimizando prompt con Groq...")
            prompt_optimizado = optimizar_prompt_con_groq(idea_usuario)
            st.code(prompt_optimizado, language="text")
            
            if modo == "Video":
                st.write("Generando video cinematográfico con Runway...")
                try:
                    ruta_video = generar_video_runway(prompt_optimizado)
                    status.update(label="¡Generación completada con éxito!", state="complete", expanded=True)
                    st.success("¡Video generado correctamente!")
                    st.video(ruta_video)
                except Exception as e:
                    status.update(label="Error en la generación", state="error", expanded=True)
                    st.error(f"Ocurrió un error al generar el video: {str(e)}")
            
            elif modo == "Audio":
                st.write("Generando locución realista con ElevenLabs...")
                try:
                    ruta_audio = generar_voz_elevenlabs(idea_usuario)
                    status.update(label="¡Locución completada!", state="complete", expanded=True)
                    st.success("¡Audio generado correctamente!")
                    st.audio(ruta_audio)
                except Exception as e:
                    status.update(label="Error en la generación de audio", state="error", expanded=True)
                    st.error(f"Ocurrió un error: {str(e)}")
            
            else:
                status.update(label="¡Listo!", state="complete", expanded=True)
                st.success("Prompt optimizado generado correctamente para el modo Imagen.")