$root = 'D:\Music' # <--- AJUSTE SUA PASTA AQUI
$apagarOriginais = $false

$sucessos = 0; $erros = 0; $pulados = 0
$ffprobe = (Get-Command ffprobe.exe -ErrorAction SilentlyContinue).Source

Write-Host "--- Auditoria de Arquivos ---" -ForegroundColor Cyan
$files = Get-ChildItem -LiteralPath $root -Filter *.flac -File -Recurse
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum
Write-Host "Arquivos FLAC: $($files.Count) | Tamanho: $([math]::Round($totalSize/1GB, 2)) GB"

foreach ($file in $files) {
    $mp3 = [System.IO.Path]::ChangeExtension($file.FullName, ".mp3")
    $tmp = $mp3 + ".tmp"
    
    if (Test-Path -LiteralPath $mp3) {
        # Valida se o MP3 existente e real usando ffprobe
        if ($ffprobe) {
            $check = & $ffprobe -v error -show_entries format=duration -of csv=p=0 $mp3 2>$null
            if ($check -and [double]$check -gt 0) {
                $pulados++; Write-Host "Validado: $($file.Name)" -ForegroundColor Gray; continue
            }
        }
        Write-Host "MP3 invalido ou incompleto: $($file.Name)" -ForegroundColor Yellow
    }

    Write-Host "Convertendo e Auditando: $($file.Name)..." -NoNewline
    ffmpeg -nostdin -v error -i $file.FullName -q:a 0 -map_metadata 0 -id3v2_version 3 $tmp
    
    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $tmp)) {
        $isValid = $false
        if ($ffprobe) {
            $res = & $ffprobe -v error -show_entries stream=codec_name:format=duration -of json $tmp 2>$null | ConvertFrom-Json
            if ($res.stream[0].codec_name -eq 'mp3' -and [double]$res.format.duration -gt 0) { $isValid = $true }
        } else { $isValid = $true }

        if ($isValid) {
            Move-Item -LiteralPath $tmp -Destination $mp3 -Force
            Write-Host " [VALIDADO]" -ForegroundColor Green
            $sucessos++
            if ($apagarOriginais) { Remove-Item -LiteralPath $file.FullName }
        } else {
            Write-Host " [CORROMPIDO]" -ForegroundColor Red
            $erros++
            if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp }
        }
    } else {
        Write-Host " [ERRO FFmpeg]" -ForegroundColor Red
        $erros++
        if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp }
    }
}

# Espera processos terminarem antes do resumo final
$p = Get-Process -Name 'ffmpeg' -ErrorAction SilentlyContinue
if ($p) { $p | Wait-Process }

Write-Host "`n--- RELATORIO DE AUDITORIA ---" -ForegroundColor Cyan
Write-Host "Sucessos Validados: $sucessos" -ForegroundColor Green
Write-Host "Falhas/Corrompidos: $erros" -ForegroundColor Red
Write-Host "Ja Validados: $pulados" -ForegroundColor Yellow
