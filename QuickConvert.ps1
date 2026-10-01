$root = 'D:\Music' # <--- AJUSTE SUA PASTA AQUI
$apagarOriginais = $false

Write-Host "Iniciando conversao rapida (V0)..." -ForegroundColor Cyan
Get-ChildItem -LiteralPath $root -Filter *.flac -Recurse | ForEach-Object {
    $mp3 = [System.IO.Path]::ChangeExtension($_.FullName, ".mp3")
    if (Test-Path -LiteralPath $mp3) { return }
    
    Write-Host "Convertendo: $($_.Name)"
    ffmpeg -nostdin -v error -i $_.FullName -q:a 0 -map_metadata 0 -id3v2_version 3 $mp3
    if ($LASTEXITCODE -eq 0 -and $apagarOriginais) { Remove-Item -LiteralPath $_.FullName }
}
Write-Host "Concluido!" -ForegroundColor Green