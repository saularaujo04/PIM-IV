<<<<<<< HEAD
# ---- build ----
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia só o necessário para o restore primeiro (aproveita cache do Docker)
COPY ["Transportadora API/Transportadora API.csproj", "Transportadora API/"]
COPY ["Transportadora.Application/Transportadora.Application.csproj", "Transportadora.Application/"]
COPY ["Transportadora.Domain/Transportadora.Domain.csproj", "Transportadora.Domain/"]
COPY ["Transportadora.Infrastructure/Transportadora.Infrastructure.csproj", "Transportadora.Infrastructure/"]
RUN dotnet restore "Transportadora API/Transportadora API.csproj"

COPY . .
RUN dotnet publish "Transportadora API/Transportadora API.csproj" -c Release -o /app/publish --no-restore /p:UseAppHost=false

# ---- runtime ----
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production

# Roda sem privilégios de root
USER app
=======
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY . .
RUN dotnet restore
RUN dotnet publish "Transportadora API/Transportadora API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Transportadora API.dll"]
