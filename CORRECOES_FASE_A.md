# Fase A — correções aplicadas

Objetivo: backend, painel web e app Flutter passarem a falar o mesmo contrato.
**Nada foi compilado nem executado ao gerar estas correções** (sem .NET/Flutter no ambiente de edição).
Valide com a checklist do final.

## Backend
- Enum `StatusEntrega` único, base 0 (removido o duplicado 1–4 e o `Compile Remove` do csproj).
- `Usuario.MotoristaId` (claim `motoristaId` no JWT) → `GET /api/entregas/minhas` filtra pelo motorista logado.
- `Motorista.Telefone` agora existe (antes o telefone era gravado em `CategoriaCnh`).
- Migration manual `20261123120000_AddMotoristaIdUsuarioETelefoneMotorista` + snapshot atualizado.
- `ClienteService`: e-mail e telefone não ficam mais trocados.
- `EntregaService`: grava origem/destino; ocorrência é salva (status + ocorrência na mesma transação); consultas devolvem `EntregaDto` (com `ocorrencias`).
- Entrega com ocorrência pode ser retomada (`IniciarRota` aceita Pendente ou Ocorrência).
- `EntregasController`: 404 para não encontrada, 409 para transição inválida; DTOs com validação (`[Required]`, `[Range]`...).
- Repositórios: `AsNoTracking` nas listagens; `AtualizarAsync` não marca mais Cliente/Motorista/Veículo como alterados.
- `script_banco.sql`: seed com as colunas obrigatórias, status 0–3, vínculo `mot@pim.com` → primeiro motorista, falha não é mais silenciosa.

## Painel web
- `wwwroot/js/app.js` compartilhado: `apiFetch` (URL relativa `/api`, envia JWT, 401 → login), `esc()` (anti-XSS), `exigirLogin`, `sair`.
- Login guarda o token e lê `usuario.perfil` corretamente; sem token as páginas redirecionam ao login.
- Removido `https://localhost:7026` de todas as páginas.
- Clientes/motoristas/veículos leem os campos reais (`razaoSocial`, `cnpj`, `categoriaCnh`...); motorista ganhou "Categoria CNH".
- Entregas: campos origem/destino, status por código, motorista vê só `/minhas`.
- Dashboard usa a contagem real de entregas por status.

## App Flutter
- Modelo, status e rotas alinhados à API real (login por e-mail; `iniciar-rota`, `concluir`, `nao-realizada`, `ocorrencia`).
- `USE_MOCK` agora é `false` por padrão; porta padrão 5178; URL via `--dart-define=API_URL=...`.
- Fila offline só descarta erros 4xx definitivos (5xx/401/408/429 mantêm a operação).
- `setup_android.ps1` gera `android/` e libera INTERNET.

## Checklist de validação (rodar nesta ordem)
1. `dotnet build` na solução (corrija qualquer erro de compilação que aparecer).
2. `dotnet ef migrations has-pending-model-changes --project Transportadora.Infrastructure --startup-project "Transportadora API"` → deve dizer que não há mudanças pendentes.
3. Banco antigo com entregas criadas antes desta correção: apague o banco (ou `UPDATE Entregas SET Status = Status - 1` nas criadas pela API) e refaça: `database update` + `script_banco.sql`.
4. Painel: login `admin@pim.com`/`123` → cadastrar cliente, motorista, veículo → criar entrega → aparece com origem/destino e status Pendente.
5. Login `mot@pim.com`/`123` no painel → só as entregas dele.
6. App (`flutter analyze`, depois `flutter run --dart-define=API_URL=...`): login, listar, iniciar, ocorrência, concluir; confira a tabela `LogHistoricoEntregas`.

<<<<<<< HEAD
## Fases seguintes
O que veio depois da Fase A (segurança, testes, deploy, front-end) está descrito em `docs/ESTADO_DO_PROJETO.md`,
com a situação de cada item. Para subir e validar tudo: `docs/RUNBOOK.md` e `verificar-ambiente.ps1`.
=======
## Fica para as próximas fases
- **B:** `Jwt:Key` fora do repositório (e trocar a atual), hash de senha, remover seed `123`, `[Authorize]` com perfis em Clientes/Motoristas/Veículos e checar que o motorista só altera as próprias entregas.
- **C:** migrations automáticas no deploy, trigger/views como migration, `USE` fora do script, banco em nuvem, Swagger/HTTPS atrás de proxy.
- **D:** APK apontando para a URL pública (remover `usesCleartextTraffic`).
- **E:** testes automatizados, paginação, FK `Usuario → Motorista`, validação de CPF/CNPJ, visual.
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
