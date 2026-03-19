# DESENVOLVIDO POR ANDRE BIMBATTI https://github.com/andrebimbatti

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

# ================= SISTEMA =================
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
$ramTotalGB = [math]::Round($cs.TotalPhysicalMemory / 1GB,2)
$discos = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$gpu = Get-CimInstance Win32_VideoController

# ================= FABRICANTE =================
$fabricante = $cs.Manufacturer
$modelo = $cs.Model

# ================= TIPO EQUIPAMENTO =================
$tipoChassi = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes
if ($tipoChassi -contains 8 -or $tipoChassi -contains 9 -or $tipoChassi -contains 10 -or $tipoChassi -contains 14) {
    $tipoEquipamento = "Notebook"
} else {
    $tipoEquipamento = "Desktop"
}

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

# ================= ATIVACAO WINDOWS =================
$licenca = Get-CimInstance SoftwareLicensingProduct |
Where-Object { $_.PartialProductKey -and $_.Name -like "*Windows*" }

if ($licenca.LicenseStatus -eq 1) {
    $statusAtivacao = "Ativado"
} else {
    $statusAtivacao = "Nao Ativado"
}

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