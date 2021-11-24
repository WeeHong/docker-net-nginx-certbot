FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS publish
WORKDIR /app
EXPOSE 5000

COPY ./dotnet/*.csproj ./src/
RUN dotnet restore

COPY ./dotnet/ ./src/
WORKDIR /app/src
RUN dotnet publish -c Release -o /app --no-restore

FROM base AS final
WORKDIR /app
COPY --from=publish /app ./
ENTRYPOINT ["dotnet", "DockerDotNET.dll"]
