# Estado do projeto

Legenda: **Validado** = rodou na máquina do autor · **Revisado** = conferido por leitura/checagens estáticas, ainda sem execução · **Pendente**.

| Etapa | Item | Situação |
|---|---|---|
| A | Contrato único API ↔ painel ↔ app (status 0–3, rotas, DTOs) | Validado (build, migrations, API, painel, app no emulador) |
| A | Migration `AddMotoristaIdUsuarioETelefoneMotorista` | Validado (`has-pending-model-changes` limpo) |
| 1 | `verificar-ambiente.ps1` e `docs/RUNBOOK.md` | Revisado (primeira execução pendente) |
| 2 | Painel web padronizado (`estilos/app.css`, `js/layout.js`, `js/app.js`) | Revisado (sintaxe JS e referências checadas) |
| 2 | App Flutter: tema, filtros, cartões, progresso, botão de mapa | Revisado (precisa de `flutter pub get` e `flutter analyze`) |
| 3 | Hash de senha, perfis por rota, limite de login, JWT por variável de ambiente | Revisado (precisa de `dotnet build` e migration `HashSenhasEObjetosSql`) |
| 3 | Migration `HashSenhasEObjetosSql` (hash das senhas, views, trigger, procedure) | Revisado (precisa de `database update` e `has-pending-model-changes`) |
| 4 | Testes xUnit (domínio, serviço, hash, CPF/CNPJ) | Revisado (precisa incluir o projeto na solução e rodar `dotnet test`) |
| 5 | Dockerfile, CI, `/health`, migrations no startup | Revisado (imagem ainda não construída) |
| 5 | Deploy na nuvem e APK de produção | Pendente (depende do provedor e do banco) |
| 6 | Fechamento (documentação final, checklist da apresentação) | Pendente |

## Pendências conhecidas
- `imask` carregado do unpkg sem versão fixa em clientes/motoristas/veículos (fixar a versão).
- Aviso de `package:flutter/material.dart` obsoleto no `flutter analyze` (informativo; migrar na versão de acabamento).
- Troca de senha só pelo próprio usuário; não há tela de administração de usuários (criar login para novos motoristas exige SQL).
- Telas do painel sem paginação (adequado para o volume do projeto).
