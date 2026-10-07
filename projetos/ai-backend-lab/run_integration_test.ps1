# Script de Teste Integrado Ponta a Ponta: Mock Server + Godot 4.7.2
param()

$serverProc = Start-Process -FilePath "python" -ArgumentList "server/mock_ai_server.py 8088" -PassThru -NoNewWindow
Start-Sleep -Seconds 1

try {
    Write-Host "[Integration] Servidor Python iniciado (PID $($serverProc.Id)). Executando cliente Godot..."
    & godot_console --headless --path . --scene res://tests/test_live_backend.tscn --quit-after 300
    $exitCode = $LASTEXITCODE
    Write-Host "[Integration] Godot finalizado com código: $exitCode"
}
finally {
    if ($serverProc -and -not $serverProc.HasExited) {
        Write-Host "[Integration] Encerrando servidor Python..."
        Stop-Process -Id $serverProc.Id -Force
    }
}

exit $exitCode
