# app.py
import customtkinter as ctk
from tkinter import filedialog, messagebox
import threading
import os
from motor_ia import (
    optimizar_prompt_con_groq, 
    generar_video_runway, 
    generar_voz_elevenlabs, 
    leer_texto_pdf, 
    escuchar_microfono, 
    GROQ_KEY
)
from groq import Groq

ctk.set_appearance_mode("Light")
ctk.set_default_color_theme("blue")

class TitanGeminiUI(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("ISAIAS TITAN STUDIO")
        self.geometry("1250800")
        self.configure(fg_color="#ffffff")

        self.modo_activo = "chat"
        self._construir_ui()

    def _construir_ui(self):
        # ---------------------------------------------------------
        # 1. PANEL LATERAL (Estilo Gemini)
        # ---------------------------------------------------------
        sidebar = ctk.CTkFrame(self, width=280, corner_radius=0, fg_color="#f0f2f5")
        sidebar.pack(side="left", fill="y")
        sidebar.pack_propagate(False)

        # Logo / Título superior
        lbl_logo = ctk.CTkLabel(sidebar, text="✨ ISAIAS TITAN", font=("Segoe UI", 16, "bold"), text_color="#1f2328")
        lbl_logo.pack(pady=20, padx=20, anchor="w")

        # Botones principales estilo Gemini
        self.crear_boton_menu(sidebar, "💬  Nueva conversación", self.limpiar_chat)
        self.crear_boton_menu(sidebar, "🔍  Buscar conversaciones", lambda: self.escribir_en_chat("ISAIAS TITAN", "Función de búsqueda de historial lista."))
        self.crear_boton_menu(sidebar, "🖼️  Imágenes y Video", lambda: self.cambiar_modo("video", "Imágenes y Video"))
        self.crear_boton_menu(sidebar, "📚  Biblioteca / PDF", lambda: self.cambiar_modo("pdf", "Biblioteca / PDF"))

        # Sección Recientes / Historial
        lbl_recientes = ctk.CTkLabel(sidebar, text="Recientes", font=("Segoe UI", 11, "bold"), text_color="#57606a")
        lbl_recientes.pack(anchor="w", padx=20, pady=(25, 5))

        self.frame_historial = ctk.CTkScrollableFrame(sidebar, fg_color="transparent", height=250)
        self.frame_historial.pack(fill="both", expand=True, padx=10, pady=5)

        self.crear_item_historial("Configurando Entorno Virtual...")
        self.crear_item_historial("Saludo Inicial y Asistencia")
        self.crear_item_historial("Investigación Física Cuántica")

        # Perfil inferior
        lbl_user = ctk.CTkLabel(sidebar, text="👤 isaias agramonte", font=("Segoe UI", 11), text_color="#24292f")
        lbl_user.pack(side="bottom", anchor="w", padx=20, pady=20)

        # ---------------------------------------------------------
        # 2. PANEL CENTRAL DE CHAT
        # ---------------------------------------------------------
        chat_container = ctk.CTkFrame(self, fg_color="#ffffff")
        chat_container.pack(side="right", fill="both", expand=True, padx=30, pady=20)

        # Indicador de Modo
        self.lbl_estado = ctk.CTkLabel(chat_container, text="Modo: 💬 Conversación General", font=("Segoe UI", 12, "bold"), text_color="#0969da")
        self.lbl_estado.pack(anchor="w", pady=(0, 10))

        # Caja de Texto del Chat
        self.caja_chat = ctk.CTkTextbox(chat_container, fg_color="#f8f9fa", text_color="#24292f", font=("Segoe UI", 12), state="disabled", border_width=1, border_color="#e1e4e8", corner_radius=12)
        self.caja_chat.pack(fill="both", expand=True, pady=(0, 15))
        
        self.escribir_en_chat("ISAIAS TITAN", "¡Hola, Isaias! Soy tu asistente inteligente definitivo. ¿Qué investigamos o creamos hoy?")

        # ---------------------------------------------------------
        # 3. BARRA DE ENCRITA INFERIOR (Estilo Gemini con Botón +, Mic y Enviar)
        # ---------------------------------------------------------
        input_card = ctk.CTkFrame(chat_container, fg_color="#f0f2f5", corner_radius=24, border_width=1, border_color="#d0d7de", height=60)
        input_card.pack(fill="x", side="bottom", pady=(0, 10))
        input_card.pack_propagate(False)

        # Botón Más (+) para adjuntar PDF / Archivos
        self.btn_mas = ctk.CTkButton(input_card, text="+", width=36, height=36, fg_color="transparent", hover_color="#e1e4e8", font=("Segoe UI", 18, "bold"), text_color="#24292f", command=self.cargar_pdf)
        self.btn_mas.pack(side="left", padx=(12, 5), pady=12)

        # Entrada de Texto Principal
        self.txt_entrada = ctk.CTkEntry(input_card, height=45, font=("Segoe UI", 12), placeholder_text="Escribe un mensaje, prompt o pega una tarea...", fg_color="transparent", text_color="#24292f", border_width=0)
        self.txt_entrada.pack(side="left", fill="x", expand=True, padx=5, pady=8)
        self.txt_entrada.bind("<Return>", lambda event: self.procesar_mensaje())

        # Botón de Micrófono (🎤)
        self.btn_mic = ctk.CTkButton(input_card, text="🎙️", width=36, height=36, fg_color="transparent", hover_color="#e1e4e8", font=("Segoe UI", 14), text_color="#24292f", command=self.usar_microfono)
        self.btn_mic.pack(side="right", padx=5, pady=12)

        # Botón de Enviar (➤)
        self.btn_enviar = ctk.CTkButton(input_card, text="➤", width=40, height=40, fg_color="#1f2328", hover_color="#32383f", font=("Segoe UI", 14, "bold"), text_color="#ffffff", corner_radius=20, command=self.procesar_mensaje)
        self.btn_enviar.pack(side="right", padx=(5, 12), pady=10)

    def crear_boton_menu(self, padre, texto, comando):
        btn = ctk.CTkButton(padre, text=texto, fg_color="transparent", text_color="#24292f", hover_color="#e1e4e8", anchor="w", height=36, font=("Segoe UI", 11), command=comando)
        btn.pack(fill="x", pady=2, padx=10)

    def crear_item_historial(self, texto):
        btn = ctk.CTkButton(self.frame_historial, text=texto, fg_color="transparent", text_color="#57606a", hover_color="#e1e4e8", anchor="w", height=30, font=("Segoe UI", 10))
        btn.pack(fill="x", pady=1)

    def cambiar_modo(self, modo, nombre_modo):
        self.modo_activo = modo
        self.lbl_estado.configure(text=f"Modo: {nombre_modo}")
        self.escribir_en_chat("ISAIAS TITAN", f"Cambiado al modo: {nombre_modo}. ¿Qué deseas procesar?")

    def escribir_en_chat(self, remitente, mensaje):
        self.caja_chat.configure(state="normal")
        self.caja_chat.insert("end", f"\n[{remitente}]:\n{mensaje}\n" + "-"*65 + "\n")
        self.caja_chat.see("end")
        self.caja_chat.configure(state="disabled")

    def limpiar_chat(self):
        self.caja_chat.configure(state="normal")
        self.caja_chat.delete("1.0", "end")
        self.escribir_en_chat("ISAIAS TITAN", "Nueva conversación iniciada. ¿En qué te ayudo?")
        self.caja_chat.configure(state="disabled")

    def cargar_pdf(self):
        ruta = filedialog.askopenfilename(filetypes=[("Archivos PDF o Documentos", "*.pdf")])
        if ruta:
            self.escribir_en_chat("ISAIAS TITAN", f"📄 Leyendo documento: {os.path.basename(ruta)}...")
            texto_pdf = leer_texto_pdf(ruta)
            
            self.escribir_en_chat("ISAIAS TITAN", "📚 Analizando contenido y extrayendo puntos clave...")
            client = Groq(api_key=GROQ_KEY)
            completion = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=[
                    {"role": "system", "content": "Eres ISAIAS TITAN. Explica, resume y resuelve el contenido del documento PDF paso a paso."},
                    {"role": "user", "content": f"Aquí está el documento:\n{texto_pdf[:4000]}"}
                ],
                temperature=0.7
            )
            self.escribir_en_chat("ISAIAS TITAN", completion.choices[0].message.content)

    def usar_microfono(self):
        self.escribir_en_chat("ISAIAS TITAN", "🎤 Escuchando por el micrófono... Habla ahora.")
        threading.Thread(target=self._hilo_microfono, daemon=True).start()

    def _hilo_microfono(self):
        texto_voz = escuchar_microfono()
        self.txt_entrada.delete(0, "end")
        self.txt_entrada.insert(0, texto_voz)
        self.escribir_en_chat("Tú (Voz)", texto_voz)

    def procesar_mensaje(self):
        texto_usuario = self.txt_entrada.get().strip()
        if not texto_usuario:
            return

        self.txt_entrada.delete(0, "end")
        self.escribir_en_chat("Tú", texto_usuario)

        threading.Thread(target=self._hilo_inteligente, args=(texto_usuario,), daemon=True).start()

    def _hilo_inteligente(self, texto):
        try:
            if self.modo_activo == "video":
                self.escribir_en_chat("ISAIAS TITAN", "🎬 Creando secuencia multimedia y video con Runway...")
                prompt_pro = optimizar_prompt_con_groq(texto)
                video_path = generar_video_runway(prompt_pro)
                audio_path = generar_voz_elevenlabs(texto)
                self.escribir_en_chat("ISAIAS TITAN", f"✅ ¡Generación completada!\n- Video: {video_path}\n- Audio: {audio_path}")
            
            else:
                client = Groq(api_key=GROQ_KEY)
                completion = client.chat.completions.create(
                    model="llama-3.3-70b-versatile",
                    messages=[
                        {"role": "system", "content": "Eres ISAIAS TITAN, una IA avanzada y conversacional. Responde de forma muy natural, empática y precisa."},
                        {"role": "user", "content": texto}
                    ],
                    temperature=0.7
                )
                self.escribir_en_chat("ISAIAS TITAN", completion.choices[0].message.content)

        except Exception as e:
            self.escribir_en_chat("ISAIAS TITAN", f"❌ Error: {str(e)}")

if __name__ == "__main__":
    app = TitanGeminiUI()
    app.mainloop()