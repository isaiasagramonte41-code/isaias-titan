import customtkinter as ctk
from motor_ia import optimizar_prompt_con_groq, generar_video_runway, generar_voz_elevenlabs
import threading

# Configuración de apariencia
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class TitanStudio(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("ISAIAS TITAN STUDIO v3.0")
        self.geometry("900x600")

        # --- Layout Principal ---
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        # 1. Barra Lateral (Sidebar)
        self.sidebar = ctk.CTkFrame(self, width=200, corner_radius=0)
        self.sidebar.grid(row=0, column=0, sticky="nsew")
        
        self.logo = ctk.CTkLabel(self.sidebar, text="⚡ TITAN", font=("Roboto", 24, "bold"))
        self.logo.pack(pady=30)
        
        self.btn_video = ctk.CTkButton(self.sidebar, text="Texto a Video", command=lambda: self.set_mode("Video"))
        self.btn_video.pack(pady=10, padx=20)
        
        self.btn_imagen = ctk.CTkButton(self.sidebar, text="Texto a Imagen", command=lambda: self.set_mode("Imagen"))
        self.btn_imagen.pack(pady=10, padx=20)

        # 2. Área Principal
        self.main_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.main_frame.grid(row=0, column=1, padx=20, pady=20, sticky="nsew")

        self.label_info = ctk.CTkLabel(self.main_frame, text="ISAIAS TITAN - Modo Video", font=("Roboto", 18))
        self.label_info.pack(pady=10)

        self.prompt_entry = ctk.CTkTextbox(self.main_frame, height=150, placeholder_text="Describe tu escena cinematográfica aquí...")
        self.prompt_entry.pack(fill="x", pady=10)

        self.btn_run = ctk.CTkButton(self.main_frame, text="🚀 GENERAR", height=50, font=("Roboto", 14, "bold"), command=self.start_process)
        self.btn_run.pack(fill="x", pady=20)

        self.console = ctk.CTkTextbox(self.main_frame, height=150, fg_color="#000")
        self.console.pack(fill="both", expand=True)

    def set_mode(self, mode):
        self.label_info.configure(text=f"ISAIAS TITAN - Modo {mode}")
        self.log(f"Cambiado a modo {mode}")

    def log(self, msg):
        self.console.insert("end", f"ISAIAS TITAN > {msg}\n")
        self.console.see("end")

    def start_process(self):
        idea = self.prompt_entry.get("1.0", "end")
        threading.Thread(target=self.run_logic, args=(idea,), daemon=True).start()

    def run_logic(self, idea):
        self.log("Analizando idea...")
        # Aquí llamarías a tus funciones de motor_ia
        self.log("¡Generación completada!")

if __name__ == "__main__":
    app = TitanStudio()
    app.mainloop()