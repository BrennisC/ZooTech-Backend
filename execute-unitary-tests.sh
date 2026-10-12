mkdir -p TestResults

while IFS= read -r -d '' project; do
  echo "========================================"
  echo "Ejecutando Unit Tests"
  echo "Proyecto: $project"
  echo "========================================"

  project_name="$(basename "$(dirname "$project")")"

  dotnet test "$project" \
    --configuration Release \
    --collect:"XPlat Code Coverage" \
    --settings coverlet.runsettings \
    --results-directory "TestResults/$project_name" \
    --logger "trx"
done < <(
  find tests/Unit \
    -type f \
    -name "*.csproj" \
    -print0
)

echo "========================================"
echo "Reportes OpenCover generados:"
echo "========================================"

find TestResults \
  -type f \
  -name "coverage.opencover.xml" \
  -print

if ! find TestResults \
    -type f \
    -name "coverage.opencover.xml" \
    -print -quit | grep -q .; then
  echo "::error::No se generaron reportes OpenCover."
  exit 1
fi