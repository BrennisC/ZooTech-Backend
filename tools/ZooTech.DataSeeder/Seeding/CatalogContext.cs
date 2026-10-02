using Microsoft.Data.SqlClient;

namespace ZooTechDataSeeder.Seeding;

/// <summary>
/// Lee de la base de datos los catalogos que YA fueron poblados por
/// "insert-common-info-in-tenants.sql" (cat_raza, cat_color, cat_tipo_adquisicion,
/// cat_tipo_utilizacion, cat_tipo_peso, geo_*). El seeder nunca inventa codigos de
/// catalogo: siempre respeta los que existen para no violar las FKs.
/// </summary>
public sealed class CatalogContext
{
    public List<string> RazaCodes { get; init; } = [];
    public List<string> ColorCodes { get; init; } = [];
    public List<string> TipoAdquisicionCodes { get; init; } = [];
    public List<string> TipoUtilizacionCodes { get; init; } = [];
    public List<string> TipoPesoCodes { get; init; } = [];
    public string DistritoCodeDefault { get; init; } = "";

    public static CatalogContext Load(SqlConnection conn)
    {
        return new CatalogContext
        {
            RazaCodes = LoadCodes(conn, "SELECT code FROM dbo.cat_raza WHERE activo = 1"),
            ColorCodes = LoadCodes(conn, "SELECT code FROM dbo.cat_color WHERE activo = 1"),
            TipoAdquisicionCodes = LoadCodes(conn, "SELECT code FROM dbo.cat_tipo_adquisicion WHERE activo = 1"),
            TipoUtilizacionCodes = LoadCodes(conn, "SELECT code FROM dbo.cat_tipo_utilizacion WHERE activo = 1"),
            TipoPesoCodes = LoadCodes(conn, "SELECT code FROM dbo.cat_tipo_peso WHERE activo = 1"),
            DistritoCodeDefault = EnsureMinimalDistrito(conn)
        };
    }

    private static List<string> LoadCodes(SqlConnection conn, string sql)
    {
        var list = new List<string>();
        using var cmd = new SqlCommand(sql, conn);
        using var reader = cmd.ExecuteReader();
        while (reader.Read()) list.Add(reader.GetString(0));
        if (list.Count == 0)
            throw new InvalidOperationException($"El catalogo consultado con '{sql}' esta vacio. Corre primero create-tenants.sql e insert-common-info-in-tenants.sql.");
        return list;
    }

    /// <summary>
    /// El script base no incluye el catalogo ubigeo (geo_departamento/provincia/distrito).
    /// Si ya cargaste el tuyo, se reutiliza el primero disponible; si no existe ninguno,
    /// se inserta un registro minimo (Huanuco / Leoncio Prado / Tingo Maria) para poder
    /// crear granjas sin bloquear el seeding por falta de ubigeo completo.
    /// </summary>
    private static string EnsureMinimalDistrito(SqlConnection conn)
    {
        using (var check = new SqlCommand("SELECT TOP 1 codigo FROM dbo.geo_distrito", conn))
        using (var reader = check.ExecuteReader())
        {
            if (reader.Read()) return reader.GetString(0);
        }

        using var tx = conn.BeginTransaction();
        using (var dep = new SqlCommand(
            "INSERT INTO dbo.geo_departamento (codigo, nombre) VALUES ('10', N'Huánuco')", conn, tx))
            dep.ExecuteNonQuery();

        using (var prov = new SqlCommand(
            "INSERT INTO dbo.geo_provincia (codigo, departamento_codigo, nombre) VALUES ('1004', '10', N'Leoncio Prado')", conn, tx))
            prov.ExecuteNonQuery();

        using (var dist = new SqlCommand(
            "INSERT INTO dbo.geo_distrito (codigo, provincia_codigo, nombre) VALUES ('100401', '1004', N'Rupa Rupa')", conn, tx))
            dist.ExecuteNonQuery();

        tx.Commit();
        return "100401";
    }
}
