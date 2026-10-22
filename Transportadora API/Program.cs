using Microsoft.EntityFrameworkCore;
using Transportadora.Application.Services;
using Transportadora.Domain.Interfaces;
using Transportadora.Infrastructure;
using Transportadora.Infrastructure.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Controllers
builder.Services.AddControllers();

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Banco em memória
builder.Services.AddDbContext<TransportadoraDbContext>(options =>
{
    options.UseInMemoryDatabase("TransportadoraDB");
});

// Repositórios
builder.Services.AddScoped<IEntregaRepository, EntregaRepository>();
builder.Services.AddScoped<IOcorrenciaRepository, OcorrenciaRepository>();

// Services
builder.Services.AddScoped<EntregaService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();