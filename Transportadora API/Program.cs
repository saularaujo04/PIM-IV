using System.Text;
<<<<<<< HEAD
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
=======
using Microsoft.AspNetCore.Authentication.JwtBearer;
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Transportadora.API.Services;
using Transportadora.Application.Services;
using Transportadora.Domain.Interfaces;
using Transportadora.Infrastructure;
using Transportadora.Infrastructure.Repositories;

var builder = WebApplication.CreateBuilder(args);

<<<<<<< HEAD
// ---------------------------------------------------------------------------
// Configuração obrigatória: a chave JWT NÃO fica no repositório.
//  - Desenvolvimento: appsettings.Development.json (chave só para uso local)
//  - Produção: variável de ambiente  Jwt__Key  (mínimo 32 caracteres)
// ---------------------------------------------------------------------------
var jwtKeyTexto = builder.Configuration["Jwt:Key"];
if (string.IsNullOrWhiteSpace(jwtKeyTexto) || jwtKeyTexto.Length < 32)
{
    throw new InvalidOperationException(
        "Jwt:Key ausente ou curta demais (mínimo 32 caracteres). " +
        "Em produção defina a variável de ambiente Jwt__Key; em desenvolvimento use appsettings.Development.json.");
}
var jwtKey = Encoding.UTF8.GetBytes(jwtKeyTexto);

=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
// Controllers
builder.Services.AddControllers();

// Swagger com suporte a Autenticação JWT (Bearer)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Transportadora API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
<<<<<<< HEAD
        Description = "Cole apenas o token JWT (sem a palavra Bearer).",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
=======
        Description = "Insira o token JWT desta forma: Bearer {seu_token}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

// Base de Dados (SQL Server)
builder.Services.AddDbContext<TransportadoraDbContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
});

<<<<<<< HEAD
// Autenticação JWT
=======
// Configuração de Autenticação JWT
var jwtKey = Encoding.ASCII.GetBytes(builder.Configuration["Jwt:Key"]!);

>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
<<<<<<< HEAD
    options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
    options.SaveToken = true;
    options.MapInboundClaims = false; // mantém os nomes curtos (sub, name, email, role)
=======
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(jwtKey),
        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidateAudience = true,
        ValidAudience = builder.Configuration["Jwt:Audience"],
<<<<<<< HEAD
        ValidateLifetime = true,
        ClockSkew = TimeSpan.FromMinutes(1),
        NameClaimType = "name",
        RoleClaimType = "role"
=======
        ValidateLifetime = true
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    };
});

builder.Services.AddAuthorization();

<<<<<<< HEAD
// Limite de tentativas de login (por IP): 10 por minuto
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddPolicy("login", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            httpContext.Connection.RemoteIpAddress?.ToString() ?? "desconhecido",
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 10,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0
            }));
});

=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
// Repositórios
builder.Services.AddScoped<IEntregaRepository, EntregaRepository>();
builder.Services.AddScoped<IOcorrenciaRepository, OcorrenciaRepository>();
builder.Services.AddScoped<IClienteRepository, ClienteRepository>();
builder.Services.AddScoped<IMotoristaRepository, MotoristaRepository>();
builder.Services.AddScoped<IVeiculoRepository, VeiculoRepository>();

<<<<<<< HEAD
// CORS: o painel é servido pela própria API (mesma origem) e o app nativo não usa CORS.
// Em desenvolvimento qualquer origem é aceita (ex.: Flutter web); em produção só as
// origens listadas em Cors:AllowedOrigins (variável Cors__AllowedOrigins__0, __1...).
var origensPermitidas = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? Array.Empty<string>();
builder.Services.AddCors(options =>
{
    options.AddPolicy("Padrao", policy =>
    {
        if (builder.Environment.IsDevelopment())
            policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
        else if (origensPermitidas.Length > 0)
            policy.WithOrigins(origensPermitidas).AllowAnyMethod().AllowAnyHeader();
    });
});

// Atrás de proxy (Render, Azure, etc.) o HTTPS termina no proxy e o container recebe HTTP.
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

=======
// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("PermitirTudo", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
// Services
builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<EntregaService>();
builder.Services.AddScoped<ClienteService>();
builder.Services.AddScoped<MotoristaService>();
builder.Services.AddScoped<VeiculoService>();

var app = builder.Build();

<<<<<<< HEAD
// Aplica as migrations ao iniciar (útil no deploy). Ligue com Database__MigrateOnStartup=true.
if (app.Configuration.GetValue<bool>("Database:MigrateOnStartup"))
{
    using var scope = app.Services.CreateScope();
    scope.ServiceProvider.GetRequiredService<TransportadoraDbContext>().Database.Migrate();
}

app.UseForwardedHeaders();

if (app.Environment.IsDevelopment() || app.Configuration.GetValue<bool>("Swagger:Enabled"))
=======
if (app.Environment.IsDevelopment())
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

<<<<<<< HEAD
if (!app.Environment.IsDevelopment())
{
    // Nunca devolve stack trace ao cliente.
    app.UseExceptionHandler(erro => erro.Run(async contexto =>
    {
        contexto.Response.StatusCode = StatusCodes.Status500InternalServerError;
        contexto.Response.ContentType = "application/json";
        await contexto.Response.WriteAsync("{\"mensagem\":\"Erro interno do servidor.\"}");
    }));
}

if (app.Configuration.GetValue<bool>("App:UseHttpsRedirection"))
    app.UseHttpsRedirection();

// Cabeçalhos de segurança básicos
app.Use(async (contexto, proximo) =>
{
    contexto.Response.Headers["X-Content-Type-Options"] = "nosniff";
    contexto.Response.Headers["X-Frame-Options"] = "DENY";
    contexto.Response.Headers["Referrer-Policy"] = "no-referrer";
    await proximo();
});

app.UseCors("Padrao");

// Serve o painel web (wwwroot)
app.UseDefaultFiles();
app.UseStaticFiles();

app.UseRateLimiter();
=======
app.UseHttpsRedirection();
app.UseCors("PermitirTudo");

// Obriga a API a ler a pasta wwwroot e servir o HTML
app.UseDefaultFiles();
app.UseStaticFiles();

>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
<<<<<<< HEAD

// Verificações de saúde (para o provedor de hospedagem)
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));
app.MapGet("/health/db", async (TransportadoraDbContext db) =>
    await db.Database.CanConnectAsync()
        ? Results.Ok(new { status = "ok", banco = "conectado" })
        : Results.StatusCode(StatusCodes.Status503ServiceUnavailable));

app.Run();
=======
app.Run();
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
