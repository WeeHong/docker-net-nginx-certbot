FROM mcr.microsoft.com/dotnet/sdk:6.0 AS publish
WORKDIR /app

COPY ./dotnet/*.csproj .
RUN dotnet restore

COPY ./dotnet/ .
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=publish /app ./
ENTRYPOINT ["dotnet", "DockerDotNET.dll"]
