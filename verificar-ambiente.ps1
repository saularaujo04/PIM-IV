<#
.SYNOPSIS
  Verifica tudo o que a aplicação TransPIM precisa para rodar (ferramentas, banco, API, segurança, rede e app).

.DESCRIPTION
  Rode na pasta raiz do projeto, com a API já iniciada (dotnet run --launch-profile http):
      powershell -ExecutionPolicy Bypass -File .\verificar-ambiente.ps1
  Opções:
      -SemFlutter   pula as verificações do app Flutter
      -ComTestes    roda também 'dotnet test' e 'flutter analyze' (demora mais)
      -ApiUrl       endereço da API (padrão http://localhost:5178)
  O script só LÊ e testa; não altera banco nem arquivos. Termina com código 1 se houver falhas.
#>
param(
    [string]$ApiUrl = 'http://localhost:5178',
    [string]$ConnectionString = 'Server=localhost;Database=TransportadoraDb;Trusted_Connection=True;TrustServerCertificate=True;',
    [string]$SenhaPadrao = '123',
    [switch]$SemFlutter,
    [switch]$ComTestes
)

$script:falhas = 0
$script:avisos = 0
$raiz = $PSScriptRoot
if (-not $raiz) { $raiz = (Get-Location).Path }

function Titulo($t) { Write-Host ''; Write-Host "== $t ==" -ForegroundColor Cyan }
function Ok($t)     { Write-Host "  [OK]    $t" -ForegroundColor Green }
function Falha($t, $dica) {
    $script:falhas++
    Write-Host "  [FALHA] $t" -ForegroundColor Red
    if ($dica) { Write-Host "          -> $dica" -ForegroundColor Yellow }
}
function Aviso($t, $dica) {
    $script:avisos++
    Write-Host "  [AVISO] $t" -ForegroundColor Yellow
    if ($dica) { Write-Host "          -> $dica" -ForegroundColor DarkYellow }
}

# ---------------------------------------------------------------- 1. ferramentas
Titulo '1. Ferramentas'
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    $v = (dotnet --version)
    if ($v -match '^(\d+)\.' -and [int]$Matches[1] -ge 8) { Ok ".NET SDK $v" }
    else { Falha ".NET SDK $v (o projeto precisa do 8 ou maior)" 'Instale o .NET 8 SDK: https://dotnet.microsoft.com/download' }

    if (dotnet tool list --global 2>$null | Select-String 'dotnet-ef') { Ok 'dotnet-ef instalado' }
    else { Falha 'dotnet-ef não encontrado' 'dotnet tool install --global dotnet-ef' }
} else {
    Falha '.NET SDK não encontrado' 'Instale o .NET 8 SDK: https://dotnet.microsoft.com/download'
}

# ---------------------------------------------------------------- 2. arquivos do projeto
Titulo '2. Arquivos do projeto'
$sln = Join-Path $raiz 'Transportadora API.sln'
if (Test-Path $sln) { Ok 'Solução encontrada (Transportadora API.sln)' }
else { Falha 'Transportadora API.sln não encontrado' "Rode o script dentro da pasta raiz do projeto (onde fica o .sln). Pasta atual: $raiz" }

$dev = Join-Path $raiz 'Transportadora API\appsettings.Development.json'
if ((Test-Path $dev) -and ((Get-Content $dev -Raw) -match '"Key"\s*:\s*"[^"]{32,}"')) { Ok 'Chave JWT de desenvolvimento configurada (appsettings.Development.json)' }
else { Falha 'Jwt:Key de desenvolvimento ausente ou curta (menos de 32 caracteres)' 'A API não inicia sem ela. Veja appsettings.Development.json.' }

$arquivosMigration = @()
$pastaMig = Join-Path $raiz 'Transportadora.Infrastructure\Migrations'
if (Test-Path $pastaMig) {
    $arquivosMigration = Get-ChildItem $pastaMig -Filter '*.cs' |
        Where-Object { $_.Name -match '^\d{14}_' -and $_.Name -notmatch '\.Designer\.cs$' } |
        ForEach-Object { $_.BaseName } | Sort-Object
    Ok "$($arquivosMigration.Count) migrations no código"
}

# ---------------------------------------------------------------- 3. banco (acesso direto)
Titulo '3. Banco de dados (SQL Server)'
$cn = $null
try {
    Add-Type -AssemblyName System.Data
    $cn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    $cn.Open()
    Ok "Conectado em $($cn.DataSource), banco $($cn.Database)"
} catch {
    Falha "Não foi possível conectar ao banco: $($_.Exception.Message)" 'Confirme que o SQL Server está rodando e que a DefaultConnection (appsettings.json) está certa. Se já tiver rodado "database update", o teste da API (seção 4) também diz se o banco responde.'
    $cn = $null
}

function Escalar($sql) {
    $cmd = $cn.CreateCommand(); $cmd.CommandText = $sql
    return $cmd.ExecuteScalar()
}

if ($cn) {
    try {
        $cmd = $cn.CreateCommand(); $cmd.CommandText = 'SELECT MigrationId FROM __EFMigrationsHistory ORDER BY MigrationId'
        $lista = @(); $rd = $cmd.ExecuteReader(); while ($rd.Read()) { $lista += $rd.GetString(0) }; $rd.Close()
        $pendentes = @($arquivosMigration | Where-Object { $lista -notcontains $_ })
        if ($pendentes.Count -eq 0) { Ok "Todas as migrations aplicadas ($($lista.Count))" }
        else { Falha "Migrations pendentes: $($pendentes -join ', ')" 'dotnet ef database update --project Transportadora.Infrastructure --startup-project "Transportadora API"' }

        $n = Escalar "SELECT COUNT(*) FROM Usuarios"
        if ($n -ge 3) { Ok "$n usuários cadastrados" } else { Falha "Só $n usuário(s) (esperado 3 de teste)" 'Rode o database update.' }

        $texto = Escalar 'SELECT COUNT(*) FROM Usuarios WHERE Senha NOT LIKE ''PBKDF2-SHA256$%'''
        if ($texto -eq 0) { Ok 'Todas as senhas estão com hash (nenhuma em texto puro)' }
        else { Falha "$texto usuário(s) com senha em texto puro" 'Rode o database update (a migration HashSenhasEObjetosSql troca as senhas de teste).' }

        $views = Escalar "SELECT COUNT(*) FROM sys.views WHERE name IN ('vw_RelatorioEntregasDetalhadas','vw_DashboardOperacional')"
        $trig = Escalar "SELECT COUNT(*) FROM sys.triggers WHERE name = 'trg_AuditStatusEntrega'"
        $log  = Escalar "SELECT COUNT(*) FROM sys.tables WHERE name = 'LogHistoricoEntregas'"
        $proc = Escalar "SELECT COUNT(*) FROM sys.procedures WHERE name = 'sp_RegistrarNovaEntrega'"
        if ($views -eq 2 -and $trig -eq 1 -and $log -eq 1 -and $proc -eq 1) { Ok 'Views, trigger de auditoria, tabela de log e procedure existem' }
        else { Falha "Objetos SQL incompletos (views=$views, trigger=$trig, log=$log, procedure=$proc)" 'Aplique as migrations: dotnet ef database update ...' }

        $ruim = Escalar "SELECT COUNT(*) FROM Entregas WHERE Status NOT BETWEEN 0 AND 3"
        if ($ruim -eq 0) { Ok 'Todos os status de entrega estão entre 0 e 3' }
        else { Falha "$ruim entrega(s) com status fora de 0 a 3 (dados do enum antigo)" 'Apague o banco e recrie: dotnet ef database drop --force ... e depois database update + script_banco.sql.' }

        $c = Escalar "SELECT COUNT(*) FROM Clientes"; $m = Escalar "SELECT COUNT(*) FROM Motoristas"
        $ve = Escalar "SELECT COUNT(*) FROM Veiculos"; $e = Escalar "SELECT COUNT(*) FROM Entregas"
        if ($c -gt 0 -and $m -gt 0 -and $ve -gt 0) { Ok "Dados: $c clientes, $m motoristas, $ve veículos, $e entregas" }
        else { Aviso 'Não há clientes/motoristas/veículos cadastrados' 'Rode o script_banco.sql (dados de exemplo) ou cadastre pelo painel.' }

        $vinc = Escalar "SELECT COUNT(*) FROM Usuarios WHERE Email = 'mot@pim.com' AND MotoristaId IS NOT NULL"
        if ($vinc -eq 1) { Ok 'Usuário mot@pim.com vinculado a um motorista' }
        else { Aviso 'mot@pim.com sem vínculo com motorista (o app mostraria lista vazia)' 'Rode o script_banco.sql, que faz o vínculo.' }
    } catch {
        Falha "Erro ao consultar o banco: $($_.Exception.Message)" 'As tabelas existem? Rode o database update.'
    } finally { $cn.Close() }
}

# ---------------------------------------------------------------- 4. API
Titulo "4. API ($ApiUrl)"
function Chamar($metodo, $caminho, $token, $corpo) {
    $h = @{}
    if ($token) { $h['Authorization'] = "Bearer $token" }
    try {
        $p = @{ Method = $metodo; Uri = "$ApiUrl$caminho"; Headers = $h; UseBasicParsing = $true; TimeoutSec = 20 }
        if ($corpo) { $p.Body = ($corpo | ConvertTo-Json); $p.ContentType = 'application/json' }
        $r = Invoke-WebRequest @p
        return [pscustomobject]@{ Status = [int]$r.StatusCode; Corpo = $r.Content }
    } catch {
        if ($_.Exception.Response) { return [pscustomobject]@{ Status = [int]$_.Exception.Response.StatusCode; Corpo = '' } }
        return [pscustomobject]@{ Status = 0; Corpo = $_.Exception.Message }
    }
}

$h = Chamar 'GET' '/health' $null $null
if ($h.Status -eq 0) {
    Falha 'API não responde' 'Suba a API em outra janela: cd "Transportadora API" ; dotnet run --launch-profile http   (aguarde "Now listening on")'
} else {
    if ($h.Status -eq 200) { Ok '/health respondeu 200' } else { Falha "/health respondeu $($h.Status)" }

    $hd = Chamar 'GET' '/health/db' $null $null
    if ($hd.Status -eq 200) { Ok 'API conectada ao banco (/health/db)' }
    else { Falha "/health/db respondeu $($hd.Status): a API não alcança o banco" 'Confira a DefaultConnection e se o database update foi aplicado.' }

    $pg = Chamar 'GET' '/login.html' $null $null
    if ($pg.Status -eq 200) { Ok 'Painel web servido pela API (/login.html)' } else { Falha "/login.html respondeu $($pg.Status)" 'Confira a pasta wwwroot.' }

    $semToken = Chamar 'GET' '/api/Entregas' $null $null
    if ($semToken.Status -eq 401) { Ok 'Rota protegida bloqueia quem não tem token (401)' }
    else { Falha "/api/Entregas sem token respondeu $($semToken.Status) (esperado 401)" 'Falta [Authorize]?' }

    $tokenAdmin = $null; $tokenMot = $null
    $la = Chamar 'POST' '/api/Auth/login' $null @{ email = 'admin@pim.com'; senha = $SenhaPadrao }
    if ($la.Status -eq 200) { $tokenAdmin = ($la.Corpo | ConvertFrom-Json).token; Ok 'Login admin@pim.com funcionou' }
    elseif ($la.Status -eq 401) { Aviso 'Login admin@pim.com recusado' "Normal se você já trocou a senha. Use -SenhaPadrao para testar com a senha atual." }
    else { Falha "Login admin respondeu $($la.Status)" 'Veja o log da janela da API.' }

    $lm = Chamar 'POST' '/api/Auth/login' $null @{ email = 'mot@pim.com'; senha = $SenhaPadrao }
    if ($lm.Status -eq 200) { $tokenMot = ($lm.Corpo | ConvertFrom-Json).token; Ok 'Login mot@pim.com funcionou' }
    elseif ($lm.Status -eq 401) { Aviso 'Login mot@pim.com recusado' 'Normal se você já trocou a senha.' }
    else { Falha "Login motorista respondeu $($lm.Status)" }

    $ruim = Chamar 'POST' '/api/Auth/login' $null @{ email = 'admin@pim.com'; senha = 'senha-errada-xyz' }
    if ($ruim.Status -eq 401) { Ok 'Senha errada é recusada (401)' } elseif ($ruim.Status -eq 429) { Aviso 'Limite de tentativas de login atingido (429): espere 1 minuto' } else { Falha "Login com senha errada respondeu $($ruim.Status) (esperado 401)" }

    if ($tokenAdmin) {
        foreach ($rota in '/api/Clientes', '/api/Motoristas', '/api/Veiculos', '/api/Entregas') {
            $r = Chamar 'GET' $rota $tokenAdmin $null
            if ($r.Status -eq 200) { Ok "Admin acessa $rota (200)" } else { Falha "Admin em $rota respondeu $($r.Status)" 'Veja o log da API.' }
        }
    }
    if ($tokenMot) {
        $r = Chamar 'GET' '/api/Entregas/minhas' $tokenMot $null
        if ($r.Status -eq 200) {
            $qtd = @($r.Corpo | ConvertFrom-Json).Count
            Ok "Motorista acessa /api/Entregas/minhas ($qtd entrega(s))"
        } else { Falha "/api/Entregas/minhas respondeu $($r.Status)" }

        foreach ($rota in '/api/Entregas', '/api/Clientes') {
            $r = Chamar 'GET' $rota $tokenMot $null
            if ($r.Status -eq 403) { Ok "Motorista não acessa $rota (403)" } else { Falha "Motorista em $rota respondeu $($r.Status) (esperado 403)" 'Perfis não estão sendo aplicados.' }
        }
    }
}

# ---------------------------------------------------------------- 5. rede e firewall
Titulo '5. Rede (para testar no celular físico)'
try {
    $escuta = Get-NetTCPConnection -LocalPort 5178 -State Listen -ErrorAction Stop
    if ($escuta) { Ok 'Algo está escutando na porta 5178' }
} catch { Aviso 'Nada escutando na porta 5178' 'A API está rodando? (dotnet run --launch-profile http)' }

try {
    $regra = Get-NetFirewallRule -DisplayName 'TransPIM API 5178' -ErrorAction Stop
    if ($regra) { Ok 'Regra de firewall "TransPIM API 5178" existe' }
} catch {
    Aviso 'Regra de firewall da porta 5178 não encontrada (só importa para celular físico)' 'PowerShell como Administrador: New-NetFirewallRule -DisplayName "TransPIM API 5178" -Direction Inbound -Protocol TCP -LocalPort 5178 -Action Allow'
}

try {
    $ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
        Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
        Select-Object -ExpandProperty IPAddress
    if ($ips) { Ok ('IP(s) deste PC na rede: ' + ($ips -join ', ') + '   (celular: --dart-define=API_URL=http://IP:5178)') }
} catch { Aviso 'Não foi possível listar o IP do PC' 'Use ipconfig.' }
Write-Host '  Emulador Android: use http://10.0.2.2:5178 (é o endereço do seu PC visto de dentro do emulador).'

# ---------------------------------------------------------------- 6. app Flutter
if (-not $SemFlutter) {
    Titulo '6. App Flutter (transpim_motorista)'
    $app = Join-Path $raiz 'transpim_motorista'
    if (-not (Test-Path $app)) { Falha 'Pasta transpim_motorista não encontrada' }
    elseif (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Falha 'Flutter não encontrado no PATH' 'https://docs.flutter.dev/get-started/install/windows' }
    else {
        Ok 'Flutter encontrado'
        $manifest = Join-Path $app 'android\app\src\main\AndroidManifest.xml'
        if (Test-Path $manifest) {
            $xml = Get-Content $manifest -Raw
            if ($xml -match 'android.permission.INTERNET') { Ok 'Manifest com permissão INTERNET' }
            else { Falha 'AndroidManifest sem a permissão INTERNET (o APK não acessaria a rede)' 'Rode transpim_motorista\setup_android.ps1' }
        } else { Falha 'Pasta android/ não existe' 'Dentro de transpim_motorista: powershell -ExecutionPolicy Bypass -File .\setup_android.ps1' }

        if (Test-Path (Join-Path $app '.dart_tool')) { Ok 'Dependências baixadas (flutter pub get)' }
        else { Aviso 'Dependências ainda não baixadas' 'Dentro de transpim_motorista: flutter pub get' }

        Push-Location $app
        try {
            $dispositivos = (flutter devices 2>&1 | Out-String)
            if ($dispositivos -match 'emulator-' -or $dispositivos -match '\(mobile\)') { Ok 'Emulador ou celular Android detectado' }
            else { Aviso 'Nenhum emulador/celular Android ligado' 'flutter emulators --launch NOME   (ou conecte o celular com Depuração USB)' }
            if ($ComTestes) {
                flutter analyze --no-fatal-infos
                if ($LASTEXITCODE -eq 0) { Ok 'flutter analyze sem erros' } else { Falha 'flutter analyze encontrou problemas' }
            }
        } finally { Pop-Location }
    }
}

# ---------------------------------------------------------------- 7. testes automatizados
Titulo '7. Testes automatizados (.NET)'
if (Test-Path $sln) {
    if (Select-String -Path $sln -Pattern 'Transportadora.Tests' -Quiet) {
        if ($ComTestes) {
            dotnet test $sln --verbosity minimal
            if ($LASTEXITCODE -eq 0) { Ok 'dotnet test passou' } else { Falha 'Há testes falhando' }
        } else { Ok 'Projeto de testes está na solução (rode com -ComTestes para executar)' }
    } else {
        Aviso 'Transportadora.Tests ainda não está na solução (o CI não roda os testes)' 'dotnet sln "Transportadora API.sln" add Transportadora.Tests\Transportadora.Tests.csproj'
    }
}

# ---------------------------------------------------------------- resumo
Write-Host ''
if ($script:falhas -eq 0) {
    Write-Host "RESULTADO: tudo certo ($($script:avisos) aviso(s))." -ForegroundColor Green
    exit 0
} else {
    Write-Host "RESULTADO: $($script:falhas) falha(s) e $($script:avisos) aviso(s). Corrija as linhas [FALHA] acima." -ForegroundColor Red
    exit 1
}
