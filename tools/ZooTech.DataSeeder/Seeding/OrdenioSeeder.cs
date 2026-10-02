using Bogus;
using Microsoft.Data.SqlClient;
using ZooTechDataSeeder.Infrastructure;

namespace ZooTechDataSeeder.Seeding;

public static class OrdenioSeeder
{
    /// <summary>
    /// Genera ordeños diarios (o casi) para cada vaca hembra adulta, en una ventana de
    /// dias reciente. Es la tabla que mas volumen aporta (N vacas x M dias).
    /// </summary>
    public static void Seed(SqlConnection conn, List<VacunoInfo> vacunos, List<long> usuarioIds,
        int diasHistoria, Faker faker)
    {
        var startId = conn.GetCurrentMaxId("ordenio") + 1;
        var now = DateTime.UtcNow;

        var vacasLecheras = vacunos
            .Where(v => v.Sexo == "HEMBRA" && (now - v.FechaNacimiento).TotalDays > 600)
            .ToList();

        var table = BulkInsertExtensions.NewTable(
            ("codigo", typeof(string)),
            ("fecha_hora", typeof(DateTime)),
            ("vacuno_id", typeof(long)),
            ("encargado_usuario_id", typeof(long)),
            ("litros", typeof(decimal)),
            ("created_at", typeof(DateTime)),
            ("updated_at", typeof(DateTime))
        );

        long nextId = startId;
        foreach (var vaca in vacasLecheras)
        {
            // No todos los dias tienen ordeño registrado (~85% de cobertura), simula huecos reales.
            for (var d = 0; d < diasHistoria; d++)
            {
                if (!faker.Random.Bool(0.85f)) continue;

                var fechaHora = now.AddDays(-d).Date.AddHours(faker.Random.Int(5, 7)).AddMinutes(faker.Random.Int(0, 59));
                // ck_ordenio_fecha (nuevo en el esquema 3FN): fecha_hora <= sysdatetime().
                // El dia d=0 puede caer en una hora todavia no alcanzada por "now" si el
                // seeder corre de madrugada; recortamos con margen de seguridad.
                if (fechaHora > now) fechaHora = now.AddMinutes(-5);

                var id = nextId++;

                table.Rows.Add(
                    $"ORD{id:D8}".Clamp(15),
                    fechaHora,
                    vaca.Id,
                    faker.PickRandom(usuarioIds),
                    faker.Random.Decimal(4.0m, 22.0m),
                    now,
                    now
                );
            }
        }

        conn.BulkInsert("ordenio", table);
    }
}
