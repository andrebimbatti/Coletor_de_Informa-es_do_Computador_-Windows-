# DESENVOLVIDO POR ANDRE BIMBATTI https://github.com/andrebimbatti

# ===== PROGRESSO INICIAL =====
Write-Output "STATUS:Iniciando"
Write-Output "PROGRESS:5"

# ================= DEFINIR PASTA (PENDRIVE) =================
$Pasta = Join-Path $PSScriptRoot "Relatorios"

if (!(Test-Path $Pasta)) {
    New-Item -ItemType Directory -Path $Pasta | Out-Null
}

$pc = $env:COMPUTERNAME
$Arquivo = Join-Path $Pasta "$pc.txt"

$usuario = $env:USERNAME
$dominio = $env:USERDOMAIN
$data = Get-Date

# ===== PROGRESSO =====
Write-Output "STATUS:Coletando sistema"
Write-Output "PROGRESS:15"

# ================= SISTEMA =================
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
$ramTotalGB = [math]::Round($cs.TotalPhysicalMemory / 1GB,2)
$discos = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$gpu = Get-CimInstance Win32_VideoController

Write-Output "Computador: $pc  |  Usuario: $usuario  |  Dominio: $dominio"

# ===== PROGRESSO =====
Write-Output "STATUS:Coletando fabricante"
Write-Output "PROGRESS:30"

# ================= FABRICANTE =================
$fabricante = $cs.Manufacturer
$modelo = $cs.Model

Write-Output "Fabricante: $fabricante  |  Modelo: $modelo"

# ===== PROGRESSO =====
Write-Output "STATUS:Identificando equipamento"
Write-Output "PROGRESS:40"

# ================= TIPO EQUIPAMENTO =================
$tipoChassi = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes
if ($tipoChassi -contains 8 -or $tipoChassi -contains 9 -or $tipoChassi -contains 10 -or $tipoChassi -contains 14) {
    $tipoEquipamento = "Notebook"
} else {
    $tipoEquipamento = "Desktop"
}

Write-Output "Tipo de equipamento: $tipoEquipamento"
Write-Output "Sistema: $($os.Caption)  |  Build: $($os.BuildNumber)"
Write-Output "Processador: $($cpu.Name)  ($($cpu.NumberOfCores) nucleos)"

# ===== PROGRESSO =====
Write-Output "STATUS:Coletando memoria"
Write-Output "PROGRESS:55"

# ================= MEMORIA RAM =================
$memorias = Get-CimInstance Win32_PhysicalMemory
$tiposMemoria = @()
$frequencias = @()

foreach ($mem in $memorias) {
    $tipo = $mem.SMBIOSMemoryType
    if (-not $tipo -or $tipo -eq 0) {
        $tipo = $mem.MemoryType
    }
    switch ($tipo) {
        20 { $tiposMemoria += "DDR" }
        21 { $tiposMemoria += "DDR2" }
        24 { $tiposMemoria += "DDR3" }
        26 { $tiposMemoria += "DDR4" }
        34 { $tiposMemoria += "DDR5" }
        default { $tiposMemoria += "Nao identificado pela BIOS" }
    }
    if ($mem.Speed) {
        $frequencias += "$($mem.Speed) MHz"
    }
}

$tipoRAM = ($tiposMemoria | Select-Object -Unique) -join ", "
$freqRAM = ($frequencias | Select-Object -Unique) -join ", "
$quantidadePentes = $memorias.Count

Write-Output "Memoria RAM: $ramTotalGB GB  |  Tipo: $tipoRAM  |  Freq: $freqRAM  |  Pentes: $quantidadePentes"

# ===== PROGRESSO =====
Write-Output "STATUS:Verificando ativacao"
Write-Output "PROGRESS:70"

# ================= ATIVACAO WINDOWS =================
$licenca = Get-CimInstance SoftwareLicensingProduct |
Where-Object { $_.PartialProductKey -and $_.Name -like "*Windows*" }

if ($licenca.LicenseStatus -eq 1) {
    $statusAtivacao = "Ativado"
} else {
    $statusAtivacao = "Nao Ativado"
}

Write-Output "Ativacao Windows: $statusAtivacao"

# ===== DISCOS =====
Write-Output "STATUS:Verificando discos"
Write-Output "PROGRESS:78"

foreach ($d in $discos) {
    $total = [math]::Round($d.Size/1GB,2)
    $livre = [math]::Round($d.FreeSpace/1GB,2)
    Write-Output "Disco $($d.DeviceID)  Total: $total GB  |  Livre: $livre GB"
}

# ===== GPU =====
Write-Output "STATUS:Verificando GPU"
Write-Output "PROGRESS:82"

foreach ($g in $gpu) {
    Write-Output "Placa de video: $($g.Name)"
}

# ===== PROGRESSO =====
Write-Output "STATUS:Gerando relatorio"
Write-Output "PROGRESS:85"

# ================= GERAR RELATORIO =================
"==============================================" | Out-File $Arquivo -Encoding UTF8
"RELATORIO DE INFORMACOES DO COMPUTADOR" | Add-Content $Arquivo
"Gerado em: $data" | Add-Content $Arquivo
"==============================================" | Add-Content $Arquivo
"" | Add-Content $Arquivo

"Nome do Computador: $pc" | Add-Content $Arquivo
"Usuario Logado: $usuario" | Add-Content $Arquivo
"Dominio/Servidor: $dominio" | Add-Content $Arquivo
"" | Add-Content $Arquivo

"===== IDENTIFICACAO DO EQUIPAMENTO =====" | Add-Content $Arquivo
"Tipo: $tipoEquipamento" | Add-Content $Arquivo
"Fabricante: $fabricante" | Add-Content $Arquivo
"Modelo: $modelo" | Add-Content $Arquivo
"Serial BIOS: $($bios.SerialNumber)" | Add-Content $Arquivo
"" | Add-Content $Arquivo

"===== WINDOWS =====" | Add-Content $Arquivo
"Sistema: $($os.Caption)" | Add-Content $Arquivo
"Versao: $($os.Version)" | Add-Content $Arquivo
"Build: $($os.BuildNumber)" | Add-Content $Arquivo
"Status de Ativacao: $statusAtivacao" | Add-Content $Arquivo
"" | Add-Content $Arquivo

"===== PROCESSADOR =====" | Add-Content $Arquivo
"Modelo: $($cpu.Name)" | Add-Content $Arquivo
"Nucleos: $($cpu.NumberOfCores)" | Add-Content $Arquivo
"" | Add-Content $Arquivo

"===== MEMORIA RAM =====" | Add-Content $Arquivo
"Total RAM: $ramTotalGB GB" | Add-Content $Arquivo
"Tipo RAM: $tipoRAM" | Add-Content $Arquivo
"Frequencia: $freqRAM" | Add-Content $Arquivo
"Quantidade de Pentes: $quantidadePentes" | Add-Content $Arquivo
"" | Add-Content $Arquivo

"===== DISCOS =====" | Add-Content $Arquivo
foreach ($d in $discos) {
    "Unidade: $($d.DeviceID) - Total: $([math]::Round($d.Size/1GB,2)) GB - Livre: $([math]::Round($d.FreeSpace/1GB,2)) GB" | Add-Content $Arquivo
}
"" | Add-Content $Arquivo

"===== PLACA DE VIDEO =====" | Add-Content $Arquivo
foreach ($g in $gpu) {
    "Placa: $($g.Name)" | Add-Content $Arquivo
}

"" | Add-Content $Arquivo
"==============================================" | Add-Content $Arquivo
"FIM DO RELATORIO" | Add-Content $Arquivo

# ===== FINAL =====
Write-Output "Relatorio salvo em: $Arquivo"
Write-Output "STATUS:Finalizado"
Write-Output "PROGRESS:100"
