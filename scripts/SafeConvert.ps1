$root = 'D:\Music' # <--- AJUSTE SUA PASTA AQUI
$apagarOriginais = $false

$sucessos = 0; $erros = 0; $pulados = 0

Write-Host "Iniciando conversao segura (com arquivos .tmp)..." -ForegroundColor Cyan
Get-ChildItem -LiteralPath $root -Filter *.flac -Recurse | ForEach-Object {
    $mp3 = [System.IO.Path]::ChangeExtension($_.FullName, ".mp3")
    $tmp = $mp3 + ".tmp"

    if (Test-Path -LiteralPath $mp3) {
        Write-Host "Pulando: $($_.Name)" -ForegroundColor Yellow
        $pulados++
        return
    }

    Write-Host "Processando: $($_.Name)..." -NoNewline
    ffmpeg -nostdin -v error -i $_.FullName -q:a 0 -map_metadata 0 -id3v2_version 3 $tmp
    
    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $tmp)) {
        Move-Item -LiteralPath $tmp -Destination $mp3 -Force
        Write-Host " [OK]" -ForegroundColor Green
        $sucessos++
        if ($apagarOriginais) { Remove-Item -LiteralPath $_.FullName }
    } else {
        Write-Host " [FALHOU]" -ForegroundColor Red
        $erros++
        if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp }
    }
}
Write-Host "`nRelatorio: Sucessos: $sucessos | Erros: $erros | Pulados: $pulados" -ForegroundColor Cyan
