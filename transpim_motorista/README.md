# TransPIM Motorista (Flutter)

Aplicativo do motorista do TMS da TransPIM (PIM IV). Telas: login, minhas
entregas, detalhe, atualizar status e registrar ocorrência. Funciona com
conexão intermitente: cópia local das entregas e fila de operações pendentes.

## Como rodar

1. Instale o Flutter (https://docs.flutter.dev/get-started/install).
2. Gere as pastas de plataforma (android/ios) dentro desta pasta:

       flutter create --project-name transpim_motorista .

   (isso NÃO apaga `lib/` nem `pubspec.yaml`; se perguntar, mantenha os nossos)
3. Instale as dependências e rode:

       flutter pub get
       flutter run

   Por padrão usa **dados simulados**. Login: qualquer usuário, senha `123`.
   No menu (⋮) há "Simular sem conexão" para testar a fila offline.

## Usando a API real

       flutter run --dart-define=USE_MOCK=false --dart-define=API_URL=http://10.0.2.2:5000

`10.0.2.2` é o endereço do seu PC visto pelo emulador Android. Em celular
físico, use o IP do PC na rede.

No Android, para API em `http://` (desenvolvimento), edite
`android/app/src/main/AndroidManifest.xml`:

- dentro de `<manifest>`: `<uses-permission android:name="android.permission.INTERNET"/>`
- na tag `<application ...>`: `android:usesCleartextTraffic="true"`

Em produção, use HTTPS e remova o `usesCleartextTraffic`.

## O que alinhar com o back-end (Saul)

- Rota `GET /api/entregas/minhas` (entregas do motorista logado): **não está** na Tabela 6 do PIM.
- Login: `POST /api/auth/login` com `{ "usuario", "senha" }` -> `{ "token" }`.
- Campos JSON de entrega: id, codigoRastreio, clienteNome, origem, destino, pesoKg,
  status (inteiro), dataPrevista, ocorrencias[{tipo, descricao, dataHora}].
- Códigos de status e de tipo de ocorrência (`lib/models/entrega.dart`).
- O app envia o cabeçalho `Idempotency-Key` nas operações de escrita; o servidor
  deve ignorar repetições com a mesma chave.

## Estrutura

    lib/
      main.dart              entrada e tema
      app_state.dart         estado, login, sincronização
      config.dart            mock x API real
      models/entrega.dart    entidades, status e ocorrências
      services/              api (contrato), http_api, mock_api, auth, fila offline
      screens/               login, entregas, detalhe, ocorrência
