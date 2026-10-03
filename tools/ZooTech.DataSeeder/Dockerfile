FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

COPY . .

RUN dotnet restore ZooTech.DataSeeder.csproj

RUN dotnet publish ZooTech.DataSeeder.csproj \
    -c Release \
    --no-restore \
    -o /app/publish


FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime

WORKDIR /app

COPY --from=build /app/publish .

# Se cambia a esto para que quede esperando al
# script .sh de seeder
ENTRYPOINT ["tail", "-f", "/dev/null"]