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

// Base de Dados (SQL Server)
builder.Services.AddDbContext<TransportadoraDbContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
});

// Repositórios
builder.Services.AddScoped<IEntregaRepository, EntregaRepository>();
builder.Services.AddScoped<IOcorrenciaRepository, OcorrenciaRepository>();
builder.Services.AddScoped<IClienteRepository, ClienteRepository>();
builder.Services.AddScoped<IMotoristaRepository, MotoristaRepository>();
builder.Services.AddScoped<IVeiculoRepository, VeiculoRepository>();

// Services
builder.Services.AddScoped<EntregaService>();
builder.Services.AddScoped<ClienteService>();
builder.Services.AddScoped<MotoristaService>();
builder.Services.AddScoped<VeiculoService>();

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