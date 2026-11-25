# TransPIM Motorista (Flutter)

Aplicativo do motorista do TMS (PIM IV): login, minhas entregas, detalhe,
iniciar rota, concluir entrega, "não realizada" e registrar ocorrência.
Funciona com conexão intermitente: cópia local das entregas e fila de operações pendentes.

## Preparar o projeto (uma vez)

A pasta `android/` não é versionada. Gere-a e libere a internet:

    # Windows (PowerShell), dentro de transpim_motorista:
    .\setup_android.ps1

Manualmente: `flutter create --project-name transpim_motorista --platforms=android .`
e depois edite `android/app/src/main/AndroidManifest.xml`:

- dentro de `<manifest>`: `<uses-permission android:name="android.permission.INTERNET"/>`
- na tag `<application ...>` (apenas para testes em HTTP): `android:usesCleartextTraffic="true"`

## Rodar contra a API local

1. Suba a API (`dotnet run --launch-profile http` na pasta `Transportadora API`; ela escuta em `0.0.0.0:5178`).
2. Libere a porta 5178 no Firewall do Windows se for testar em celular físico.
3. Rode o app:

       flutter pub get
       flutter run --dart-define=API_URL=http://10.0.2.2:5178        # emulador Android
       flutter run --dart-define=API_URL=http://192.168.1.15:5178    # celular na mesma rede (IP do PC)

Login de teste: `mot@pim.com` / `123` (o `script_banco.sql` vincula esse usuário ao primeiro motorista,
senão `/api/entregas/minhas` devolve lista vazia).

## Gerar o APK

    flutter build apk --release --dart-define=API_URL=https://SEU-DOMINIO-PUBLICO

> **Atenção:** o app usa a API real por padrão. O modo simulado só liga com `--dart-define=USE_MOCK=true`
> (aí vale qualquer e-mail com a senha `123` e o menu ⋮ tem "Simular sem conexão").
> A URL é definida na hora do build (`--dart-define=API_URL=...`), não no código.

## Contrato com a API (backend é a fonte da verdade)

| Ação no app | Chamada |
|---|---|
| Login | `POST /api/auth/login` `{ email, senha }` -> `{ token, usuario }` |
| Listar | `GET /api/entregas/minhas` (usa o claim `motoristaId` do token) |
| Iniciar trajeto / Retomar | `POST /api/entregas/{id}/iniciar-rota` |
| Confirmar entrega | `POST /api/entregas/{id}/concluir` |
| Entrega não realizada | `POST /api/entregas/{id}/nao-realizada` |
| Registrar ocorrência | `POST /api/entregas/{id}/ocorrencia` `{ descricao }` (o tipo vira prefixo do texto) |

Status (iguais ao enum `StatusEntrega` do C# e ao SQL): `0` Pendente, `1` Em trânsito, `2` Concluída, `3` Ocorrência.
Registrar uma ocorrência (ou "não realizada") coloca a entrega em `3`; dela o motorista pode retomar o trajeto.

Fila offline: erros 4xx definitivos (ex.: transição inválida) descartam a operação; erros temporários
(5xx, 401, 408, 429, sem rede) mantêm a operação na fila.

## Estrutura

    lib/
      main.dart              entrada e tema
      app_state.dart         estado, login, sincronização
      config.dart            URL da API e modo simulado (--dart-define)
      models/entrega.dart    entidades e status
      services/              api (contrato), http_api, mock_api, auth, fila offline
      screens/               login, entregas, detalhe, ocorrência
