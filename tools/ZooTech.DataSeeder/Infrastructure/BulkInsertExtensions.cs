using System.Data;
using Microsoft.Data.SqlClient;

namespace ZooTechDataSeeder.Infrastructure;

/// <summary>
/// Helper central para insertar volumen alto de filas usando SqlBulkCopy en vez de
/// INSERT fila por fila (mucho mas rapido para miles/millones de registros).
///
/// SUPUESTO CLAVE (documentado): el seeder corre en modo exclusivo contra la base
/// (nadie mas escribe al mismo tiempo). Gracias a eso, antes de insertar un lote
/// calculamos el MAX(id) actual y asignamos en memoria los ids siguientes de forma
/// contigua (max+1, max+2, ...) EN EL MISMO ORDEN en que se agregan las filas al
/// DataTable. SqlBulkCopy respeta ese orden y la columna id es IDENTITY, asi que el
/// valor que la base termina asignando coincide con el que ya calculamos. Esto evita
/// tener que hacer un SELECT ... OUTPUT / round-trip para recuperar ids generados y
/// nos permite usarlos de inmediato como FK para tablas hijas (ordenio, triaje, etc.).
///
/// Si el batch completo falla (constraint, tipo de dato, etc.) SqlBulkCopy aborta
/// toda la operacion (no hace commits parciales de un mismo batch), asi que el
/// supuesto de "ids contiguos" se mantiene: o se insertaron todas las filas del
/// batch con los ids previstos, o no se inserto ninguna.
/// </summary>
public static class BulkInsertExtensions
{
    public static long GetCurrentMaxId(this SqlConnection conn, string table, string idColumn = "id", SqlTransaction? tx = null)
    {
        using var cmd = new SqlCommand($"SELECT ISNULL(MAX({idColumn}), 0) FROM dbo.{table} WITH (TABLOCKX)", conn, tx);
        var result = cmd.ExecuteScalar();
        return result is null or DBNull ? 0L : Convert.ToInt64(result);
    }

    public static void BulkInsert(this SqlConnection conn, string table, DataTable data, SqlTransaction? tx = null, int batchSize = 5000)
    {
        if (data.Rows.Count == 0) return;

        using var bulk = tx is null
            ? new SqlBulkCopy(conn)
            : new SqlBulkCopy(conn, SqlBulkCopyOptions.Default, tx);

        bulk.DestinationTableName = $"dbo.{table}";
        bulk.BatchSize = batchSize;
        bulk.BulkCopyTimeout = 0; // sin limite, son cargas de prueba

        foreach (DataColumn col in data.Columns)
        {
            bulk.ColumnMappings.Add(col.ColumnName, col.ColumnName);
        }

        bulk.WriteToServer(data);
    }

    public static DataTable NewTable(params (string Name, Type Type)[] columns)
    {
        var table = new DataTable();
        foreach (var (name, type) in columns)
        {
            table.Columns.Add(name, Nullable.GetUnderlyingType(type) ?? type);
        }
        return table;
    }

    /// <summary>Trunca un string al maximo de caracteres permitido por la columna (varchar corto).</summary>
    public static string Clamp(this string value, int maxLength)
        => value.Length <= maxLength ? value : value[..maxLength];
}
