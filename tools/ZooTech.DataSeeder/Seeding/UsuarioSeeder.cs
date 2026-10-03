using System.Data;
using Bogus;
using Microsoft.Data.SqlClient;
using ZooTechDataSeeder.Infrastructure;

namespace ZooTechDataSeeder.Seeding;

public static class UsuarioSeeder
{
    /// <summary>Inserta N usuarios y devuelve la lista de ids generados (contiguos).</summary>
    public static List<long> Seed(SqlConnection conn, int cantidad, Faker faker)
    {
        var startId = conn.GetCurrentMaxId("usuario") + 1;
        var table = BulkInsertExtensions.NewTable(
            ("codigo", typeof(string)),
            ("nombre_usuario", typeof(string)),
            ("nombre_completo", typeof(string)),
            ("correo", typeof(string)),
            ("activo", typeof(bool)),
            ("created_at", typeof(DateTime)),
            ("updated_at", typeof(DateTime))
        );

        var ids = new List<long>(cantidad);
        for (var i = 0; i < cantidad; i++)
        {
            var id = startId + i;
            var nombre = faker.Name.FullName();
            var login = faker.Internet.UserName().Clamp(50).ToLowerInvariant();
            var correo = faker.Internet.Email().Clamp(120);
            var now = DateTime.UtcNow;

            Console.WriteLine($"Usuario generado: {nombre} -> {correo}");

            table.Rows.Add(
                $"USR{id:D8}".Clamp(15),
                $"{login}{id}".Clamp(50),
                nombre.Clamp(100),
                correo,
                true,
                now,
                now
            );
            ids.Add(id);
        }

        conn.BulkInsert("usuario", table);
        return ids;
    }
}
