using Microsoft.EntityFrameworkCore;
using Transportadora.Infrastructure; // Adicione o namespace de onde está o seu DbContext

var builder = WebApplication.CreateBuilder(args);

// Adiciona os serviços de Controller e Swagger (padrão da API)
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// INÍCIO DO PASSO 2 - Injeção do Banco de Dados
builder.Services.AddDbContext<TransportadoraDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
// FIM DO PASSO 2

var app = builder.Build();

// Configura o pipeline de requisições HTTP (Swagger etc)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();