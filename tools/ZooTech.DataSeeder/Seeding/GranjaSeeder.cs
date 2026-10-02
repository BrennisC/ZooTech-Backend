using System.Data;
using Bogus;
using Microsoft.Data.SqlClient;
using ZooTechDataSeeder.Infrastructure;

namespace ZooTechDataSeeder.Seeding;

public static class GranjaSeeder
{
    public static List<long> Seed(SqlConnection conn, int cantidad, string distritoCodigo, Faker faker)
    {
        var startId = conn.GetCurrentMaxId("granja") + 1;
        var table = BulkInsertExtensions.NewTable(
            ("nombre", typeof(string)),
            ("distrito_codigo", typeof(string)),
            ("activo", typeof(bool)),
            ("created_at", typeof(DateTime)),
            ("updated_at", typeof(DateTime))
        );

        var ids = new List<long>(cantidad);
        for (var i = 0; i < cantidad; i++)
        {
            var id = startId + i;
            var now = DateTime.UtcNow;

            // granja.nombre es varchar(100) en el esquema 3FN (antes varchar(15)), asi que ya
            // no hace falta un nombre tan apretado.
            table.Rows.Add(
                $"Fundo {faker.Address.City()} {i + 1:D3}".Clamp(100),
                distritoCodigo,
                true,
                now,
                now
            );
            ids.Add(id);
        }

        conn.BulkInsert("granja", table);
        return ids;
    }
}
