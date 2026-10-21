using Microsoft.EntityFrameworkCore;
using Transportadora.Application.Services;
using Transportadora.Domain.Interfaces;
using Transportadora.Infrastructure;
using Transportadora.Infrastructure.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Serviços da API
builder.Services.AddControllers();

// Banco de dados em memória
builder.Services.AddDbContext<TransportadoraDbContext>(options =>
{
    options.UseInMemoryDatabase("TransportadoraDB");
});

// Repositórios
builder.Services.AddScoped<IEntregaRepository, EntregaRepository>();

// Serviços da aplicação
builder.Services.AddScoped<EntregaService>();

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Pipeline HTTP
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();