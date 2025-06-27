# Build aşaması
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Proje dosyalarını kopyala ve restore et
COPY src/WebApi/*.csproj ./ 
RUN dotnet restore

# Kaynak kodlarını kopyala
COPY src/WebApi/. ./

# Yayınla (publish)
RUN dotnet publish -c Release -o out

# Runtime aşaması
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/out ./

EXPOSE 8080

ENTRYPOINT ["dotnet", "dotnet-otel-collector-demo.dll"]
