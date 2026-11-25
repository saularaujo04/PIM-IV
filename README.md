<<<<<<< HEAD
# 🚚 PIM IV — Sistema de Gestão de Transportes (TMS)

Projeto acadêmico (PIM IV): plataforma logística com **API .NET 8**, **painel web** (HTML/JS servido pela própria API) e **app mobile do motorista** (Flutter).

| Peça | Tecnologia | Pasta |
|---|---|---|
| API + regras de negócio | .NET 8, EF Core, SQL Server, JWT, Clean Architecture | `Transportadora API`, `Transportadora.Application`, `.Domain`, `.Infrastructure` |
| Painel web (admin/operador) | HTML, Bootstrap, JS | `Transportadora API/wwwroot` |
| App do motorista | Flutter (Material 3) | `transpim_motorista` |
| Testes automatizados | xUnit | `Transportadora.Tests` |

Status da entrega (INT no banco, enum `StatusEntrega`, SQL e app): `0` Pendente · `1` Em trânsito · `2` Concluída · `3` Ocorrência.

## Rodar localmente
Guia completo, com tabela de erros comuns: [`docs/RUNBOOK.md`](docs/RUNBOOK.md). Resumo, na pasta raiz:

1. **Banco** (tabelas, views, trigger de auditoria, procedure, senhas com hash):

       dotnet ef database update --project Transportadora.Infrastructure --startup-project "Transportadora API"

2. **Dados de exemplo** (opcional, reexecutável): abra `script_banco.sql` no SSMS, selecione `TransportadoraDb` e execute.
3. **API + painel:**

       cd "Transportadora API"
       dotnet run --launch-profile http

   Painel: <http://localhost:5178/login.html> · Swagger (só em desenvolvimento): <http://localhost:5178/swagger>
4. **App:** veja [`transpim_motorista/README.md`](transpim_motorista/README.md).
5. **Conferir tudo:** `powershell -ExecutionPolicy Bypass -File .\verificar-ambiente.ps1`

Usuários de teste (senha inicial `123`; troque no menu **Alterar senha**): `admin@pim.com` (admin), `log@pim.com` (operador), `mot@pim.com` (motorista).

## Segurança
- Senhas guardadas com PBKDF2-SHA256; login com limite de 10 tentativas por minuto por IP.
- Rotas protegidas por perfil (`admin`, `operador`, `motorista`); o motorista só altera as próprias entregas.
- A chave JWT **não** fica no repositório: em desenvolvimento vem de `appsettings.Development.json`; em produção, da variável `Jwt__Key`.
- Cadastros validam CPF/CNPJ e placa.

## Endpoints principais
| Método | Rota | Quem |
|---|---|---|
| POST | `/api/auth/login` · `/api/auth/alterar-senha` | todos |
| GET/POST | `/api/clientes` (POST só admin), `/api/motoristas`, `/api/veiculos` | admin, operador |
| GET/POST | `/api/entregas` | admin, operador |
| GET | `/api/entregas/minhas` | motorista logado |
| POST | `/api/entregas/{id}/iniciar-rota` · `/concluir` · `/nao-realizada` · `/ocorrencia` | motorista (só as próprias), admin, operador |
| GET | `/health` · `/health/db` | público (monitoramento) |

## Testes e CI
    dotnet sln "Transportadora API.sln" add Transportadora.Tests\Transportadora.Tests.csproj   # uma vez
    dotnet test "Transportadora API.sln"

O workflow em `.github/workflows` compila, roda os testes e valida a imagem Docker a cada push.

## Documentação
- [`docs/RUNBOOK.md`](docs/RUNBOOK.md) — subir e validar tudo, problemas comuns
- [`docs/DEPLOY.md`](docs/DEPLOY.md) — publicação na nuvem e APK (rascunho a validar)
- [`docs/ESTADO_DO_PROJETO.md`](docs/ESTADO_DO_PROJETO.md) — o que está pronto, o que foi validado e o que falta
=======
# 🚚 TransPIM TMS — Sistema de Gestão de Transportes

![.NET 8](https://img.shields.io/badge/.NET-8.0-512BD4?style=flat-square&logo=dotnet&logoColor=white)
![C#](https://img.shields.io/badge/C%23-12-239120?style=flat-square&logo=csharp&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-SSMS%2022-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?style=flat-square&logo=flutter&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Alpine-2496ED?style=flat-square&logo=docker&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-0F172A?style=flat-square)

> **Projeto Integrado Multidisciplinar IV (PIM IV)**  
> **Curso Superior de Tecnologia em Análise e Desenvolvimento de Sistemas**  
> **Universidade Paulista (UNIP)** • São Paulo, 2026

Plataforma corporativa integrada de ponta a ponta (*Transport Management System*) projetada para apoiar a transformação digital da **TransPIM Transportes e Logística**. O ecossistema substitui controles manuais em planilhas e comunicações informais por uma solução centralizada que conecta a gestão administrativa no escritório (**Painel Web**) aos motoristas em campo (**Aplicativo Mobile**), orquestrados por uma **API RESTful** estruturada sob **Clean Architecture** e persistência relacional em **SQL Server**.

---

## 📑 Sumário

- [Visão Geral e Problema Resolvido](#-visão-geral-e-problema-resolvido)
- [Arquitetura do Ecossistema](#-arquitetura-do-ecossistema)
- [Stack Tecnológica e Ferramentas](#-stack-tecnológica-e-ferramentas)
- [Estrutura do Repositório](#-estrutura-do-repositório)
- [Engenharia de Banco de Dados](#-engenharia-de-banco-de-dados)
- [Endpoints da API REST](#-endpoints-da-api-rest)
- [Guia de Execução Local](#-guia-de-execução-local)
- [Implantação com Docker](#-implantação-com-docker)
- [Mapeamento Acadêmico (PIM IV)](#-mapeamento-acadêmico-pim-iv)
- [Autores e Orientação](#-autores-e-orientação)

---

## 🎯 Visão Geral e Problema Resolvido

A **TransPIM Transportes e Logística** (cenário organizacional de médio porte com cerca de 60 colaboradores e frota própria de 35 veículos) opera modalidades de carga fracionada, carga fechada (lotação) e entregas urbanas na região metropolitana de São Paulo e capitais do Sudeste.

Para eliminar gargalos operacionais como falhas de comunicação por telefone, risco de alocação duplicada de frota e ausência de rastreabilidade histórica, o sistema oferece:

1. **Centralização Operacional (Backoffice Web):** Cadastro e manutenção de clientes, motoristas, veículos e despacho de ordens de entrega com validação de integridade referencial.
2. **Operação em Campo (App Mobile):** Consulta de rotas atribuídas ao motorista autenticado, transição de status em tempo real (`Pendente` → `Em Trânsito` → `Concluída` ou `Ocorrência`) e resiliência para operação com sinal intermitente.
3. **Rastreabilidade e Auditoria:** Geração automática de código de rastreio (`TRK-XXXXXX`), painel consolidado de indicadores e registro automático de cada alteração de status no banco de dados.
4. **Conformidade e Inclusão:** Coleta mínima de dados pessoais alinhada à **LGPD (Lei nº 13.709/2018)** e interfaces projetadas sob diretrizes de acessibilidade **WCAG 2.1**.

---

## 🏗️ Arquitetura do Ecossistema

A solução segue rigorosamente a **Regra de Dependência da Clean Architecture**, mantendo as entidades e regras de negócio isoladas de detalhes externos de infraestrutura, banco de dados e interface:

```text
┌────────────────────────────┐      ┌───────────────────────────────────────────┐
│   Painel Web Admin (SPA)   │      │      App Mobile Motorista (Flutter)       │
│ HTML5 • CSS3 • JS (Fetch)  │      │      transpim_motorista (Dart/Android)    │
└─────────────┬──────────────┘      └─────────────────────┬─────────────────────┘
              │  HTTPS / JWT (Porta 7026)                 │  HTTP / JWT (Porta 5178)
              └────────────────────┬──────────────────────┘
                                   ▼
            ┌──────────────────────────────────────────────┐
            │         Transportadora.API (.NET 8)          │
            │  Controllers REST • Swagger • JWT • wwwroot  │
            └──────────────────────┬───────────────────────┘
                                   │
            ┌──────────────────────▼───────────────────────┐
            │     Transportadora.Application (.NET 8)      │
            │        Services (Casos de Uso) • DTOs        │
            └──────────────────────┬───────────────────────┘
                                   │
            ┌──────────────────────▼───────────────────────┐
            │        Transportadora.Domain (.NET 8)        │
            │    Entidades • Enums • Interfaces Repo       │
            └──────────────────────▲───────────────────────┘
                                   │ (Implementação & EF Core)
            ┌──────────────────────┴───────────────────────┐
            │    Transportadora.Infrastructure (.NET 8)    │
            │   DbContext • Migrations • Repositórios      │
            └──────────────────────┬───────────────────────┘
                                   │
            ┌──────────────────────▼───────────────────────┐
            │        Microsoft SQL Server (T-SQL)          │
            │  Tabelas • Views • Trigger • Stored Proc     │
            └──────────────────────────────────────────────┘
```

---

## 🛠️ Stack Tecnológica e Ferramentas

### Ambientes de Desenvolvimento e Emulação
* **Visual Studio 2022:** IDE principal utilizada para desenvolvimento da solução `Transportadora API.sln`, depuração das camadas .NET, gestão de pacotes NuGet, execução de *migrations* e edição das interfaces Web em `wwwroot`.
* **SQL Server Management Studio 22 (SSMS 22):** Ambiente administrativo utilizado para gerenciamento da instância SQL Server (`TransportadoraDb`), execução do `script_banco.sql` e validação de *Views*, *Triggers*, *Stored Procedures* e auditoria.
* **Android Studio:** Plataforma utilizada para criação e gerenciamento de dispositivos virtuais (AVD / Emulador Android), compilação e depuração do aplicativo mobile `transpim_motorista`.

### Tecnologias por Camada
| Camada | Tecnologias | Responsabilidade |
| :--- | :--- | :--- |
| **Back-end / API** | C# 12, .NET 8, ASP.NET Core Web API, Swagger, JWT Bearer | Regras de negócio, autenticação por token, documentação OpenAPI e hospedagem dos estáticos Web. |
| **Persistência / ORM** | Entity Framework Core (*Code-First*), SQL Server (T-SQL) | Mapeamento objeto-relacional, controle de esquema via *migrations* e objetos programáveis no banco. |
| **Front-end Web** | HTML5, CSS3 (`global.css`), JavaScript Vanilla (`app.js`) | Painel administrativo servido via `wwwroot`, consumindo a API de forma assíncrona pela *Fetch API*. |
| **Aplicativo Mobile** | Flutter & Dart (`transpim_motorista`) | Aplicativo nativo do motorista com alternância Mock/HTTP, armazenamento seguro de sessão e fila offline. |
| **DevOps & Cloud** | Docker (*multi-stage* Linux Alpine), Git & GitHub | Empacotamento unificado da API e do front-end Web para implantação escalável em nuvem. |

---

## 📂 Estrutura do Repositório

```text
PIM-IV-main/
├── Transportadora API.sln               # Solução principal no Visual Studio 2022
├── Dockerfile                           # Build multi-stage para deploy em contêiner
├── script_banco.sql                     # Views, Trigger de auditoria, Procedure e Seed inicial
├── CORRECOES_FASE_A.md                  # Histórico de estabilização técnica da Fase 1
├── README.md                            # Documentação principal do repositório
│
├── Transportadora.Domain/               # Camada Core (sem dependências externas)
│   ├── Entidades/
│   │   ├── EntidadeBase.cs              # Classe base com Id e DataCriacao
│   │   ├── Cliente.cs                   # Dados cadastrais do cliente embarcador
│   │   ├── Motorista.cs                 # Dados do motorista, CNH, categoria e telefone
│   │   ├── Veiculo.cs                   # Frota, placa, modelo e capacidade (kg)
│   │   ├── Entrega.cs                   # Entidade central do ciclo logístico
│   │   ├── OcorrenciaEntrega.cs         # Registro detalhado de ocorrências em rota
│   │   └── Usuario.cs                   # Credenciais, perfil e vínculo com MotoristaId
│   ├── Enums/
│   │   └── StatusEntrega.cs             # 0: Pendente | 1: Em Trânsito | 2: Concluída | 3: Ocorrência
│   └── Interfaces/                      # Contratos IClienteRepository, IEntregaRepository, etc.
│
├── Transportadora.Application/          # Camada de Casos de Uso
│   ├── DTOs/                            # CriarClienteDto, CriarEntregaDto, CriarMotoristaDto, CriarVeiculoDto, CriarOcorrenciaDto, EntregaDto
│   └── Services/                        # ClienteService, EntregaService, MotoristaService, VeiculoService
│
├── Transportadora.Infrastructure/       # Camada de Acesso a Dados (EF Core + SQL Server)
│   ├── Migrations/                      # Histórico de migrações (InitialCreate até AddMotoristaIdUsuarioETelefoneMotorista)
│   ├── Repositorios/                    # ClienteRepository, EntregaRepository, MotoristaRepository, VeiculoRepository, OcorrenciaRepository
│   ├── TransportadoraDbContext.cs       # Contexto EF Core e configuração das entidades
│   └── TransportadoraDbContextFactory.cs# Fábrica em tempo de design para CLI dotnet-ef
│
├── Transportadora API/                  # Camada de Apresentação e Host Web
│   ├── Controllers/                     # AuthController, ClientesController, MotoristasController, VeiculosController, EntregasController
│   ├── Services/
│   │   └── TokenService.cs              # Emissão e assinatura de tokens JWT Bearer
│   ├── Properties/
│   │   └── launchSettings.json          # Perfis de execução (HTTPS :7026 e HTTP :5178)
│   ├── wwwroot/                         # Painel Web Administrativo servido pela API
│   │   ├── CSS/global.css               # Estilização global responsiva e acessível
│   │   ├── js/app.js                    # Utilitários de autenticação, Fetch API e controle de sessão
│   │   ├── login.html                   # Autenticação de usuários no painel
│   │   ├── index.html                   # Dashboard operacional com indicadores
│   │   ├── clientes.html                # Gestão de clientes
│   │   ├── motoristas.html              # Gestão de motoristas
│   │   ├── veiculos.html                # Gestão de frota
│   │   └── entregas.html                # Despacho e acompanhamento de entregas
│   ├── Program.cs                       # Configuração de DI, CORS, JWT, Swagger e Static Files
│   └── appsettings.json                 # String de conexão SQL Server e chaves JWT
│
└── transpim_motorista/                  # Aplicativo Mobile do Motorista (Flutter)
    ├── pubspec.yaml                     # Dependências do projeto Dart/Flutter
    └── lib/
        ├── main.dart                    # Ponto de entrada e inicialização de estado
        ├── config.dart                  # Alternância entre modo Mock/HTTP e definição da BaseUrl
        ├── app_state.dart               # Gerenciamento reativo de sessão e lista de entregas
        ├── models/entrega.dart          # Modelo de dados e serialização JSON
        ├── screens/                     # login_screen.dart, entregas_screen.dart, detalhe_screen.dart, ocorrencia_screen.dart
        └── services/                    # api.dart, auth_service.dart, http_api.dart, mock_api.dart, sync_queue.dart
```

---

## 🗄️ Engenharia de Banco de Dados (`TransportadoraDb`)

O banco de dados relacional atende à Terceira Forma Normal (3FN). As tabelas estruturais são versionadas pelas *migrations* do Entity Framework Core, enquanto o arquivo `script_banco.sql` complementa o banco no **SSMS 22** com objetos programáveis que garantem integridade e auditoria no nível do SGBD:

| Objeto SQL | Tipo | Descrição Técnica |
| :--- | :--- | :--- |
| **`LogHistoricoEntregas`** | Tabela | Armazena o histórico imutável de transições (`EntregaId`, `StatusAnterior`, `StatusNovo`, `DataAlteracao`, `UsuarioSistema`). |
| **`trg_AuditStatusEntrega`** | Trigger (`AFTER UPDATE`) | Intercepta alterações na coluna `Status` de `Entregas` utilizando as tabelas virtuais `deleted` e `inserted` e insere o log automaticamente. |
| **`sp_RegistrarNovaEntrega`** | Stored Procedure | Executa sob transação explícita (`BEGIN TRANSACTION` / `ROLLBACK` no `CATCH`), valida existência de Cliente, Motorista e Veículo, gera o código `TRK-XXXXXX` e cria a entrega como `0 (Pendente)`. |
| **`vw_RelatorioEntregasDetalhadas`** | View | Consolida os `JOIN`s entre entregas, clientes, motoristas e veículos, convertendo o status numérico para texto descritivo. |
| **`vw_DashboardOperacional`** | View | Agrega os indicadores totais (`TotalEntregas`, `QtdPendentes`, `QtdEmTransito`, `QtdConcluidas`, `QtdOcorrencias`) para consumo do painel Web. |

### Ciclo de Vida da Entrega (`StatusEntrega`)
* **`0` — Pendente:** Ordem criada pelo despachante no painel Web e aguardando início de rota.
* **`1` — Em Trânsito:** Motorista acionou *Iniciar Rota* no aplicativo mobile.
* **`2` — Concluída:** Entrega finalizada e confirmada no destino.
* **`3` — Ocorrência:** Registro de imprevisto durante o trajeto (ausência, avaria, atraso).

---

## 🌐 Endpoints da API REST

| Recurso | Método | Rota | Descrição |
| :--- | :--- | :--- | :--- |
| **Autenticação** | `POST` | `/api/auth/login` | Autentica usuário e retorna o token JWT Bearer. |
| **Clientes** | `GET`, `POST`, `PUT`, `DELETE` | `/api/clientes` | CRUD completo de clientes embarcadores. |
| **Motoristas** | `GET`, `POST`, `PUT`, `DELETE` | `/api/motoristas` | CRUD completo de motoristas e CNH. |
| **Veículos** | `GET`, `POST`, `PUT`, `DELETE` | `/api/veiculos` | CRUD completo de veículos da frota. |
| **Entregas** | `GET`, `POST` | `/api/entregas` | Consulta de entregas e criação de novas ordens. |
| **Status / Rota** | `PATCH` / `PUT` | `/api/entregas/{id}/status` | Atualiza o status da entrega e dispara a trigger de auditoria. |

---

## 🚀 Guia de Execução Local

### Pré-requisitos
* **Visual Studio 2022** com carga de trabalho *ASP.NET e desenvolvimento Web* (.NET 8 SDK)
* **SQL Server** + **SQL Server Management Studio 22 (SSMS 22)**
* **Flutter SDK** + **Android Studio** (com dispositivo virtual Android configurado)

### Passo 1 — Banco de Dados (EF Core & SSMS 22)
1. Confira a string `DefaultConnection` em `Transportadora API/appsettings.json`.
2. Abra o terminal na raiz do projeto, instale a ferramenta `dotnet-ef` compatível com o .NET 8 e aplique as *migrations*:
   ```powershell
   dotnet tool install --global dotnet-ef --version 8.0.10
   dotnet ef database update --project Transportadora.Infrastructure --startup-project "Transportadora API"
   ```
3. Abra o **SSMS 22**, conecte-se ao seu servidor SQL, abra o arquivo `script_banco.sql` e pressione **F5 (Executar)** para criar as *Views*, a *Trigger*, a *Stored Procedure* e carregar os registros iniciais de demonstração.

### Passo 2 — Iniciar a API e o Painel Web (Visual Studio 2022 ou CLI)
* **Via Visual Studio 2022:** Abra `Transportadora API.sln`, defina `Transportadora API` como projeto de inicialização e pressione **F5** utilizando o perfil `https`.
* **Via Terminal:**
  ```powershell
  cd "Transportadora API"
  dotnet run --launch-profile https
  ```
* **Endereços locais ativos:**
  * **Painel Web Admin:** `https://localhost:7026/login.html`
  * **Documentação Swagger:** `https://localhost:7026/swagger`
  * **Escuta HTTP para Mobile (Rede Local):** `http://0.0.0.0:5178`

### Passo 3 — Executar o Aplicativo Mobile (Android Studio)
1. Inicie um emulador Android (AVD) pelo **Android Studio**.
2. Verifique a URL base em `transpim_motorista/lib/config.dart` e `transpim_motorista/lib/services/http_api.dart`:
   * **Para Emulador Android Studio (AVD):** utilize `http://10.0.2.2:5178` (alias padrão do emulador para o `localhost` da máquina hospedeira).
   * **Para Aparelho Físico via Wi-Fi:** utilize o IPv4 local da máquina (ex.: `http://192.168.1.15:5178`) e libere a porta `5178` no Firewall do Windows:
     ```powershell
     New-NetFirewallRule -DisplayName "PIM-IV API HTTP" -Direction Inbound -LocalPort 5178 -Protocol TCP -Action Allow
     ```
3. Execute o aplicativo Flutter:
   ```powershell
   cd transpim_motorista
   flutter pub get
   flutter run
   ```

---

## 🐳 Implantação com Docker

O `Dockerfile` na raiz do repositório utiliza *multi-stage build* para compilar a solução com o SDK .NET 8 e gerar uma imagem enxuta baseada em ASP.NET Linux Alpine contendo a API e os arquivos estáticos da pasta `wwwroot`:

```powershell
# Construir a imagem
docker build -t transpim-tms-api .

# Executar o contêiner mapeando a porta 8080
docker run -d -p 8080:8080 --name transpim-tms transpim-tms-api
```

---

## 🎓 Mapeamento Acadêmico (PIM IV)

| Etapa / Disciplina | Implementação no Repositório |
| :--- | :--- |
| **Etapa 1:** Caracterização da Organização | Modelagem das entidades `Cliente`, `Motorista`, `Veiculo`, `Entrega` e `OcorrenciaEntrega` refletindo a rotina da TransPIM. |
| **Etapa 2:** Empreendedorismo em TI | Separação estratégica entre painel gerencial Web (escritório) e app mobile operacional (campo), maximizando ROI e rastreabilidade. |
| **Etapa 3:** Relações Étnico-Raciais e Inclusão | Minimização de dados pessoais conforme a **LGPD** (ausência de campos discriminatórios) e interfaces acessíveis segundo **WCAG 2.1**. |
| **Etapa 4:** Desenvolvimento Web com .NET | ASP.NET Core 8 Web API, Swagger, autenticação JWT Bearer, CORS e front-end SPA em `wwwroot` via *Fetch API*. |
| **Etapa 5:** Desenvolvimento Mobile | Aplicativo Flutter (`transpim_motorista`) testado no Android Studio com desacoplamento `MockApi`/`HttpApi` e fila offline (`SyncQueue`). |
| **Etapa 6:** Programação Aplicada em .NET | Clean Architecture em 4 camadas, orientação a objetos (`EntidadeBase`), padrões *Repository* e *DTO* e Injeção de Dependência no Visual Studio 2022. |
| **Etapa 7:** Programação de Banco de Dados | Modelo normalizado (3FN) no SQL Server via SSMS 22, *migrations* EF Core, `trg_AuditStatusEntrega`, `sp_RegistrarNovaEntrega` e *Views*. |
| **Etapa 8:** Cloud Computing e DevOps | Containerização *multi-stage* via `Dockerfile`, arquitetura *stateless* com JWT e versionamento contínuo no GitHub. |
| **Etapa 9:** Gerenciamento de Projetos Ágil | Desenvolvimento incremental conduzido com Scrum e Kanban ao longo de 5 sprints e 4 fases de homologação. |
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
