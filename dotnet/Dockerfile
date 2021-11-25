FROM mcr.microsoft.com/dotnet/sdk:6.0 AS base
WORKDIR /app
COPY DockerDotNET.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:6.0
# Very important
ENV ASPNETCORE_URLS=http://+:5000
WORKDIR /app
COPY --from=base /app/publish .
ENTRYPOINT ["dotnet", "DockerDotNET.dll"] 