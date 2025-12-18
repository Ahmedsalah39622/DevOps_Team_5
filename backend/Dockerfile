# Use the official .NET SDK image for build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY Smart_CityOps/Smart_CityOps/Smart_CityOps.csproj ./Smart_CityOps/
RUN dotnet restore ./Smart_CityOps/Smart_CityOps.csproj

# Copy everything else and build
COPY Smart_CityOps/. ./Smart_CityOps/
WORKDIR /app/Smart_CityOps
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
COPY --from=build /app/Smart_CityOps/out ./
ENTRYPOINT ["dotnet", "Smart_CityOps.dll"]