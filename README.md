# 📊 Coletor de Informações do Computador (Windows)

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)
![Platform](https://img.shields.io/badge/Platform-Windows-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow)
![Version](https://img.shields.io/badge/Version-1.0-informational)

Script em **PowerShell + BAT** para coletar automaticamente informações detalhadas de um computador Windows e gerar um relatório em `.txt`.

Ideal para:
- Inventário de máquinas
- Auditoria de hardware
- Suporte técnico
- Levantamento de parque de TI

---

## 🚀 Funcionalidades

O script coleta e gera um relatório contendo:

### 🖥️ Informações Gerais
- Nome do computador
- Usuário logado
- Domínio/servidor
- Data de execução

### 💻 Sistema Operacional
- Versão do Windows
- Build
- Status de ativação

### 🧠 Hardware
- Processador (modelo e núcleos)
- Memória RAM:
  - Total
  - Tipo (DDR, DDR2, DDR3, DDR4, DDR5)
  - Frequência
  - Quantidade de pentes
- Disco:
  - Espaço total
  - Espaço livre
- Placa de vídeo

### 🏷️ Identificação do Equipamento
- Tipo (Desktop ou Notebook)
- Fabricante
- Modelo
- Serial da BIOS

---

## 📂 Estrutura do Projeto
📁 projeto/
├── coletar_dados.ps1 # Script principal (PowerShell)
├── coletar_dados.bat # Executador simples
└── Relatorios/ # Pasta gerada automaticamente


---

## ▶️ Como Usar

### 🔹 Método 1 (Mais fácil)
1. Coloque os arquivos em um **pendrive** ou pasta
2. Execute:
coletar_dados.bat

✔ Isso irá:
- Rodar o script PowerShell
- Criar a pasta `Relatorios`
- Gerar um arquivo com nome do PC (ex: `PC01.txt`)

---

### 🔹 Método 2 (Direto no PowerShell)
powershell -ExecutionPolicy Bypass -File coletar_dados.ps1

---

## 📄 Saída

O relatório será salvo em:
Relatorios/NOME-DO-PC.txt

Exemplo:
RELATORIO DE INFORMACOES DO COMPUTADOR

Nome do Computador: PC01
Usuario Logado: admin

===== WINDOWS =====
Sistema: Windows 10 Pro
Versao: 10.0.19045
Status de Ativacao: Ativado

===== MEMORIA RAM =====
Total RAM: 8 GB
Tipo RAM: DDR4


---

## 🔐 Permissões

O script usa:

- `Get-CimInstance`
- Informações de hardware e sistema

💡 Recomendado executar como **Administrador** para garantir coleta completa.

---

## ⚠️ Observações

- Funciona apenas em **Windows**
- Não envia dados para internet (100% local)
- Pode ser usado em massa via:
  - PSTools
  - Script de logon
  - Execução remota

---
## 🌐 Uso em Rede (GPO / Active Directory)

Por padrão, os relatórios são salvos localmente na máquina.

Para uso em ambiente corporativo com GPO, recomenda-se salvar os arquivos em um servidor de rede.

### 🔧 Alteração necessária

No arquivo `coletar_dados.ps1`, altere:

```powershell
$pasta = "Relatorios"
Para um caminho de rede:
$pasta = "\\SERVIDOR\Inventario\Relatorios"

📁 Resultado

Cada computador irá gerar seu próprio arquivo no servidor:
\\SERVIDOR\Inventario\Relatorios\PC01.txt
\\SERVIDOR\Inventario\Relatorios\PC02.txt

⚠️ Permissões

Certifique-se de que os computadores do domínio possuem permissão de escrita na pasta de rede.

Exemplo:

Domínio\Computadores → Permissão de escrita


## 🛠️ Possíveis Melhorias

- Exportar para CSV ou Excel
- Envio automático para servidor
- Interface gráfica (GUI) ✔️ 24/05/2026
- Coleta de rede (IP, MAC, etc.)
- Integração com Active Directory

---

## 👨‍💻 Autor

Desenvolvido por:  
**Andre Bimbatti**  
🔗 https://github.com/andrebimbatti
