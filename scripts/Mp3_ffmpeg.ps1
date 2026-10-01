$pasta  = "C:\Users\samne\OneDrive\Documents\Soulseek Downloads\complete"   # ajuste para a sua pasta
$apagar = $false         # troque para $true só depois de testar

# --- Variáveis de Log ---
$totalArquivos = 0
$sucessos = 0
$erros = 0
$pulados = 0

Write-Host "Iniciando processamento... Por favor, aguarde." -ForegroundColor Cyan

Get-ChildItem -LiteralPath $pasta -Filter *.flac -Recurse | ForEach-Object {
    $totalArquivos++
    $flac = $_.FullName
    $mp3  = [System.IO.Path]::ChangeExtension($flac, ".mp3")

    if (Test-Path -LiteralPath $mp3) {
        Write-Host "Ja existe, pulando: $mp3" -ForegroundColor Yellow
        $pulados++
        return
    }

    # 1) Converter (qualidade V0, mantem as tags)
    ffmpeg -nostdin -v error -i $flac -map_metadata 0 -c:a libmp3lame -q:a 0 -id3v2_version 3 $mp3
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRO na conversao: $flac" -ForegroundColor Red
        Remove-Item -LiteralPath $mp3 -ErrorAction SilentlyContinue
        $erros++
        return
    }

    # 2) Verificar integridade: decodifica o MP3 inteiro procurando erros
    $errosDecode = ffmpeg -nostdin -v error -i $mp3 -f null - 2>&1
    $okDecode = ($LASTEXITCODE -eq 0) -and (-not $errosDecode)

    # 3) Comparar duracoes (tolerancia de 1 segundo)
    $durFlac = [double](ffprobe -v error -show_entries format=duration -of csv=p=0 $flac)
    $durMp3  = [double](ffprobe -v error -show_entries format=duration -of csv=p=0 $mp3)
    $okDur   = [math]::Abs($durFlac - $durMp3) -lt 1

    if ($okDecode -and $okDur) {
        Write-Host "OK: $mp3" -ForegroundColor Green
        $sucessos++
        if ($apagar) { Remove-Item -LiteralPath $flac }
    } else {
        Write-Host "FALHOU na verificacao (FLAC mantido): $mp3" -ForegroundColor Magenta
        $erros++
    }
}

# --- Relatório Final ---
Write-Host "`n" + ("=" * 30) -ForegroundColor Cyan
Write-Host "      RELATÓRIO FINAL" -ForegroundColor Cyan
Write-Host ("=" * 30) -ForegroundColor Cyan
Write-Host "Total de FLACs encontrados: $totalArquivos"
Write-Host "Convertidos com sucesso:    $sucessos" -ForegroundColor Green
Write-Host "Arquivos com erro/falha:    $erros" -ForegroundColor Red
Write-Host "Arquivos já existentes:     $pulados" -ForegroundColor Yellow
Write-Host ("=" * 30) -ForegroundColor Cyan