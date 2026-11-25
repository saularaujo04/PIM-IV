# Runbook — como subir e validar o TransPIM

Guia de operação do projeto (Windows + SQL Server local). Para conferir tudo de uma vez:

    powershell -ExecutionPolicy Bypass -File .\verificar-ambiente.ps1

O script só lê e testa (não altera nada) e aponta o que está faltando.

## 1. Pré-requisitos
| Item | Para quê | Como conferir |
|---|---|---|
| .NET 8 SDK | API | `dotnet --version` |
| `dotnet-ef` | migrations | `dotnet tool list --global` (instalar: `dotnet tool install --global dotnet-ef`) |
| SQL Server (ex.: localhost) + SSMS | banco | conectar em `localhost` com autenticação do Windows |
| Flutter SDK + Android SDK (com NDK) | app | `flutter doctor` (itens de Chrome/Visual Studio podem ficar com `[!]`) |
| Emulador Android ou celular com Depuração USB | testar o app | `flutter devices` |

## 2. Primeira vez (uma só vez)
Todos os comandos na **pasta raiz** do projeto (onde está `Transportadora API.sln`), exceto quando indicado.

1. **Banco e estrutura** (tabelas, views, trigger, procedure e senhas com hash):

       dotnet ef database update --project Transportadora.Infrastructure --startup-project "Transportadora API"

2. **Dados de exemplo:** no SSMS, abra `script_banco.sql`, selecione o banco `TransportadoraDb` e execute. Pode rodar de novo sem duplicar.
3. **Testes automatizados** (uma vez, para incluir o projeto de testes na solução):

       dotnet sln "Transportadora API.sln" add Transportadora.Tests\Transportadora.Tests.csproj
       dotnet test "Transportadora API.sln"

4. **App Flutter:** dentro de `transpim_motorista`:

       powershell -ExecutionPolicy Bypass -File .\setup_android.ps1
       flutter pub get

## 3. Dia a dia — subir tudo, nesta ordem
1. **API** (janela própria, fica aberta): primeiro entre na pasta, depois rode.

       cd "Transportadora API"
       dotnet run --launch-profile http

   Espere `Now listening on: http://0.0.0.0:5178`. Painel: <http://localhost:5178/login.html>.
2. **Emulador:** `flutter emulators --launch Medium_Phone_API_37.0` (o ID aparece em `flutter emulators`). Aguarde a tela inicial do Android.
3. **App** (outra janela, dentro de `transpim_motorista`):

       flutter run -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:5178

   Celular físico (mesma rede Wi-Fi): troque pelo IP do PC (`ipconfig`) e libere a porta (veja a seção 5).
4. **Conferência:** `.\verificar-ambiente.ps1` na raiz.

> Atenção ao colar vários comandos: o `cd` precisa vir **antes** do `dotnet run` / `flutter run`.

## 4. Contas e dados de teste
| Perfil | E-mail | Senha inicial | Vê |
|---|---|---|---|
| Administrador | `admin@pim.com` | `123` | tudo (cadastros, entregas) |
| Operador | `log@pim.com` | `123` | motoristas, veículos, entregas |
| Motorista | `mot@pim.com` | `123` | só as próprias entregas (app) |

- Troque as senhas depois do primeiro acesso (menu **Alterar senha** no painel).
- O cadastro agora valida CPF/CNPJ/placa. Para testar use valores válidos, por exemplo:
  CPF `529.982.247-25`, CNPJ `11.222.333/0001-81`, placa `ABC-1D23`.
- O motorista só enxerga entregas se o usuário dele estiver vinculado a um cadastro de motorista
  (o `script_banco.sql` faz isso para `mot@pim.com`).

## 5. Rede: emulador x celular físico
| Onde roda o app | Valor de `API_URL` |
|---|---|
| Emulador Android | `http://10.0.2.2:5178` |
| Celular na mesma rede | `http://<IP do PC>:5178` (descubra com `ipconfig`) |
| Produção | `https://<seu-domínio>` |

Para celular físico, libere a porta no firewall (PowerShell como **Administrador**):

    New-NetFirewallRule -DisplayName "TransPIM API 5178" -Direction Inbound -Protocol TCP -LocalPort 5178 -Action Allow

Teste antes: abra `http://<IP do PC>:5178/login.html` no navegador do celular.

## 6. Configuração por variáveis de ambiente (produção)
O `appsettings.json` não guarda segredos. Em produção defina:

| Variável | Valor |
|---|---|
| `Jwt__Key` | chave secreta com 32+ caracteres (**obrigatória**; a API não inicia sem ela) |
| `ConnectionStrings__DefaultConnection` | string de conexão do SQL Server na nuvem |
| `Database__MigrateOnStartup` | `true` para aplicar migrations ao iniciar |
| `Cors__AllowedOrigins__0` | só se algum site de outra origem for consumir a API |
| `Swagger__Enabled` | `true` apenas para depurar (padrão `false`) |
| `ASPNETCORE_ENVIRONMENT` | `Production` (já é o padrão do Dockerfile) |

A chave que existia no repositório antes está comprometida: **nunca** use a mesma em produção.

## 7. Problemas comuns
| Sintoma | Causa | Solução |
|---|---|---|
| `MSB1003: Especifique um arquivo de solução ou de projeto` | comando rodado fora da pasta do projeto | `cd` até a pasta com o `.sln` |
| `Não foi possível localizar um projeto para executar` | `dotnet run` na raiz | `cd "Transportadora API"` antes |
| `Error: No pubspec.yaml file found` | `flutter run` fora de `transpim_motorista` | `cd transpim_motorista` |
| Login do painel: "E-mail ou senha inválidos" e API devolve 500 | banco não criado/atualizado | `dotnet ef database update ...` |
| `Impossível conectar-se ao servidor remoto` | API parada | subir a API (seção 3) |
| API fecha ao iniciar: `Jwt:Key ausente ou curta` | falta a chave | em desenvolvimento use `appsettings.Development.json`; em produção `Jwt__Key` |
| Login devolve 429 | limite de 10 tentativas por minuto por IP | aguarde 1 minuto |
| Motorista recebe 403 em `/api/Clientes` | comportamento esperado (perfis) | use admin/operador no painel |
| Cadastro recusa CPF/CNPJ | validação de dígitos verificadores | use um documento válido |
| App: lista vazia para `mot@pim.com` | usuário sem vínculo com motorista | rodar `script_banco.sql` |
| `No supported devices found ... emulator-5554` | emulador desligado | `flutter emulators --launch ...` e esperar abrir |
| Build Android: `NDK ... not found` | NDK não instalado | Android Studio → SDK Manager → SDK Tools → NDK (Side by side) |
| Emulador: `Windows Hypervisor Platform is not enabled` | recurso do Windows desligado | `Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All` (Admin) e reiniciar |
| Entregas antigas com status estranho | enum antigo (1–4) | apagar e recriar o banco (`database drop --force`, `database update`, `script_banco.sql`) |
| Avisos `deprecated_member_use` no `flutter analyze` | Flutter novo trocando `material.dart` | só informativo; migrar na fase de acabamento |
