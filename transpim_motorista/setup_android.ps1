# Prepara a pasta android/ do app (ela não é versionada no repositório).
# Execute DENTRO de transpim_motorista:   .\setup_android.ps1
# Requer o Flutter SDK no PATH. (Script não testado em todas as versões do Flutter:
# se algo falhar, siga os passos manuais do README.)

flutter create --project-name transpim_motorista --platforms=android .

# O flutter create gera um teste padrão que referencia outro app e quebra o `flutter analyze`.
if (Test-Path "test/widget_test.dart") { Remove-Item "test/widget_test.dart" }

$manifest = "android/app/src/main/AndroidManifest.xml"
$xml = Get-Content $manifest -Raw

# Sem INTERNET o APK de release não acessa a rede (só o modo debug tem a permissão).
if ($xml -notmatch 'android.permission.INTERNET') {
    $xml = $xml -replace '(<manifest[^>]*>)', "`$1`n    <uses-permission android:name=`"android.permission.INTERNET`"/>"
}

# Permite HTTP puro (só para testar na rede local). Em produção use HTTPS e remova esta linha.
if ($xml -notmatch 'usesCleartextTraffic') {
    $xml = $xml -replace '<application', '<application android:usesCleartextTraffic="true"'
}

Set-Content $manifest $xml -Encoding UTF8
Write-Host "OK. Agora rode: flutter pub get ; flutter run --dart-define=API_URL=http://10.0.2.2:5178"
