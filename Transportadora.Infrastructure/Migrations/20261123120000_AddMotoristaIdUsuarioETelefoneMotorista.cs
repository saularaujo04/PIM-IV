using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Transportadora.Infrastructure;

#nullable disable

namespace Transportadora.Infrastructure.Migrations
{
    /// <summary>
    /// Adiciona o telefone do motorista e o vínculo opcional Usuario -> Motorista
    /// (usado por GET /api/entregas/minhas para filtrar as entregas do motorista logado).
    /// Escrita à mão; para regenerar o Designer, apague este arquivo e rode:
    ///   dotnet ef migrations add AddMotoristaIdUsuarioETelefoneMotorista
    /// </summary>
    [DbContext(typeof(TransportadoraDbContext))]
    [Migration("20261123120000_AddMotoristaIdUsuarioETelefoneMotorista")]
    public partial class AddMotoristaIdUsuarioETelefoneMotorista : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Telefone",
                table: "Motoristas",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "MotoristaId",
                table: "Usuarios",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Telefone",
                table: "Motoristas");

            migrationBuilder.DropColumn(
                name: "MotoristaId",
                table: "Usuarios");
        }
    }
}
