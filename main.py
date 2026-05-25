import tkinter as tk
from tkinter import ttk
import subprocess
import threading
import winsound
import os
import sys

BG_COLOR = "#1e1e1e"
FG_COLOR = "#ffffff"
ACCENT   = "#4cc2ff"

# Caminho absoluto do script PS1, na mesma pasta do main.py
SCRIPT_DIR = os.path.dirname(os.path.abspath(sys.argv[0]))
PS1_PATH   = os.path.join(SCRIPT_DIR, "coletar_dados.ps1")

# ===== ATUALIZA PROGRESSO (THREAD SAFE) =====
def atualizar_progresso(valor):
    root.after(0, lambda: progress.configure(value=valor))

# ===== ATUALIZA STATUS =====
def atualizar_status(texto):
    root.after(0, lambda: status_var.set(texto))

# ===== LOG =====
def adicionar_log(texto):
    def update():
        log_text.insert(tk.END, texto + "\n")
        log_text.see(tk.END)
    root.after(0, update)

# ===== EXECUÇÃO =====
def executar_script():
    btn.config(state="disabled")

    def tarefa():
        try:
            atualizar_progresso(0)
            atualizar_status("Iniciando...")
            adicionar_log(">>> Iniciando coleta de dados...")

            processo = subprocess.Popen(
                [
                    "powershell",
                    "-ExecutionPolicy", "Bypass",
                    "-WindowStyle", "Hidden",
                    "-File", PS1_PATH
                ],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,   # stderr junto com stdout
                text=True,
                encoding="utf-8",
                errors="replace"
            )

            for linha in processo.stdout:
                linha = linha.strip()
                if not linha:
                    continue

                if linha.startswith("PROGRESS:"):
                    try:
                        valor = int(linha.split(":")[1])
                        atualizar_progresso(valor)
                    except:
                        pass

                elif linha.startswith("STATUS:"):
                    status = linha.split(":", 1)[1]
                    atualizar_status(status)

                else:
                    adicionar_log(linha)

            processo.wait()
            atualizar_status("Concluído com sucesso!")
            atualizar_progresso(100)
            adicionar_log(">>> Coleta finalizada!")
            winsound.MessageBeep()

        except Exception as e:
            atualizar_status("Erro ao executar")
            adicionar_log(f"ERRO: {e}")

        finally:
            root.after(0, lambda: btn.config(state="normal"))

    threading.Thread(target=tarefa, daemon=True).start()

# ===== UI =====
root = tk.Tk()
root.title("Coletor de Informações")
root.geometry("520x420")
root.resizable(False, False)
root.configure(bg=BG_COLOR)

style = ttk.Style()
style.theme_use("default")
style.configure("TLabel",      background=BG_COLOR, foreground=FG_COLOR, font=("Segoe UI", 10))
style.configure("Title.TLabel", font=("Segoe UI", 16, "bold"))
style.configure("TButton",     background="#2d2d2d", foreground=FG_COLOR, padding=6)
style.map("TButton",           background=[("active", ACCENT), ("disabled", "#444444")])
style.configure("TProgressbar", troughcolor="#2d2d2d", background=ACCENT)

# ===== TÍTULO =====
ttk.Label(root, text="Coletor de Informações", style="Title.TLabel").pack(pady=(15, 5))

# ===== BOTÃO =====
btn = ttk.Button(root, text="Iniciar Coleta", command=executar_script)
btn.pack(pady=8)

# ===== BARRA =====
progress = ttk.Progressbar(root, mode="determinate", maximum=100)
progress.pack(fill="x", padx=20, pady=(8, 4))

# ===== STATUS =====
status_var = tk.StringVar(value="Aguardando execução...")
ttk.Label(root, textvariable=status_var).pack(pady=(2, 6))

# ===== LOG =====
log_text = tk.Text(
    root,
    height=10,
    bg="#151515",
    fg="#00ff9c",
    insertbackground="white",
    borderwidth=0,
    font=("Consolas", 9),
    state="normal"
)
log_text.pack(fill="both", expand=True, padx=20, pady=(0, 15))

# ===== RUN =====
root.mainloop()
