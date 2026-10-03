using Bogus;
using Microsoft.Data.SqlClient;
using ZooTechDataSeeder.Seeding;

// ---------------------------------------------------------------------------
// Uso:
//   dotnet run --project ZooTechDataSeeder -- \
//     --conn "Server=localhost,1433;Database=ZooTech_AltoHuallaga_Db;User Id=sa;Password=...;TrustServerCertificate=True" \
//     --usuarios 15 --granjas 5 --vacunos 5000 --dias-ordenio 180 --seed 42
//
// Todos los parametros son opcionales excepto --conn. Valores por defecto abajo.
// ---------------------------------------------------------------------------

var options = ParseArgs(args);

Console.WriteLine($"Conectando a: {options.ConnDisplay}");
using var conn = new SqlConnection(options.ConnectionString);
conn.Open();

var faker = new Faker("es");
Randomizer.Seed = new Random(options.Seed);

Console.WriteLine("Cargando/validando catalogos existentes...");
var catalogos = CatalogContext.Load(conn);

Console.WriteLine($"Sembrando {options.Usuarios} usuarios...");
var usuarioIds = UsuarioSeeder.Seed(conn, options.Usuarios, faker);

Console.WriteLine($"Sembrando {options.Granjas} granjas...");
var granjaIds = GranjaSeeder.Seed(conn, options.Granjas, catalogos.DistritoCodeDefault, faker);

Console.WriteLine($"Sembrando {options.Vacunos} vacunos (fundadores + crias)...");
var vacunos = VacunoSeeder.Seed(conn, options.Vacunos, granjaIds, usuarioIds, catalogos, faker);

Console.WriteLine($"Sembrando ordeños ({options.DiasOrdenio} dias de historia por vaca lechera)...");
OrdenioSeeder.Seed(conn, vacunos, usuarioIds, options.DiasOrdenio, faker);

Console.WriteLine("Sembrando triajes (control de peso cada ~30 dias por vacuno)...");
TriajeSeeder.Seed(conn, vacunos, usuarioIds, catalogos, faker);

Console.WriteLine("Listo. Resumen:");
Console.WriteLine($"  usuario : {usuarioIds.Count}");
Console.WriteLine($"  granja  : {granjaIds.Count}");
Console.WriteLine($"  vacuno  : {vacunos.Count}");
Console.WriteLine("Para agregar celo_registro / fecundacion / fecundacion_cria, sigue el mismo");
Console.WriteLine("patron (crear un Seeder que reciba 'vacunos' y use BulkInsertExtensions).");

return;

static SeedOptions ParseArgs(string[] args)
{
    string? conn = null;
    var usuarios = 20;
    var granjas = 8;
    var vacunos = 5000;
    var diasOrdenio = 180;
    var seed = 42;

    for (var i = 0; i < args.Length; i++)
    {
        switch (args[i])
        {
            case "--conn": conn = args[++i]; break;
            case "--usuarios": usuarios = int.Parse(args[++i]); break;
            case "--granjas": granjas = int.Parse(args[++i]); break;
            case "--vacunos": vacunos = int.Parse(args[++i]); break;
            case "--dias-ordenio": diasOrdenio = int.Parse(args[++i]); break;
            case "--seed": seed = int.Parse(args[++i]); break;
        }
    }

    if (string.IsNullOrWhiteSpace(conn))
        throw new ArgumentException("Falta --conn \"<connection string>\"");

    return new SeedOptions(conn, usuarios, granjas, vacunos, diasOrdenio, seed);
}

internal sealed record SeedOptions(string ConnectionString, int Usuarios, int Granjas, int Vacunos, int DiasOrdenio, int Seed)
{
    public string ConnDisplay => new SqlConnectionStringBuilder(ConnectionString) { Password = "***" }.ConnectionString;
}
