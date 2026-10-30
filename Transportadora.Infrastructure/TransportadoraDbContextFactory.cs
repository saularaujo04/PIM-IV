using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Transportadora.Infrastructure;

public class TransportadoraDbContextFactory : IDesignTimeDbContextFactory<TransportadoraDbContext>
{
    public TransportadoraDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<TransportadoraDbContext>();
        optionsBuilder.UseSqlServer("Server=localhost;Database=TransportadoraDb;Trusted_Connection=True;TrustServerCertificate=True;");

        return new TransportadoraDbContext(optionsBuilder.Options);
    }
}