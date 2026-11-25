# Deploy — visão geral (rascunho a validar)

> Esta etapa **ainda não foi executada nem testada**: depende de escolher o provedor e criar as contas.
> O código já está preparado: Dockerfile enxuto e sem root, migrations (incluindo views, trigger e procedure)
> aplicáveis na inicialização, `/health` e `/health/db`, cabeçalhos de segurança, tratamento de proxy (HTTPS) e
> configuração por variáveis de ambiente.

## O que precisa existir
1. **Banco SQL Server na nuvem** (ex.: Azure SQL Database). Anote a string de conexão.
2. **Hospedagem de contêiner** que aceite Docker (ex.: Render, Azure App Service para contêineres, Railway).
3. **URL pública com HTTPS** (o provedor entrega o certificado).

## Passo a passo (genérico)
1. Suba o repositório no GitHub (o CI roda build, testes e valida a imagem Docker).
2. Crie o serviço apontando para o `Dockerfile` da raiz.
3. Defina as variáveis de ambiente (ver tabela no `RUNBOOK.md`, seção 6):
   `Jwt__Key`, `ConnectionStrings__DefaultConnection`, `Database__MigrateOnStartup=true`.
   Se o provedor exigir a porta por variável, defina `PORT=8080` (a imagem escuta em 8080).
4. Firewall do banco: libere o IP de saída do provedor de hospedagem.
5. Após o primeiro deploy, confira `https://<domínio>/health` e `https://<domínio>/health/db`.
6. **Troque as senhas de teste** (admin, operador, motorista) logo no primeiro acesso.
7. Se quiser dados de exemplo, rode `script_banco.sql` no banco da nuvem (opcional; não use em produção real).

## APK apontando para a nuvem
    cd transpim_motorista
    flutter build apk --release --dart-define=API_URL=https://<seu-domínio>

- Em produção o app usa HTTPS; o `usesCleartextTraffic="true"` do manifest só é necessário para testes locais em HTTP
  (remova-o do `AndroidManifest.xml` antes de gerar o APK final).
- O APK sai em `build\app\outputs\flutter-apk\app-release.apk`.
- Para publicar em loja seria preciso assinatura própria; para a banca basta instalar o APK no celular.
