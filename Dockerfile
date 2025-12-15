# 使用 .NET 10.0 运行时镜像作为基础
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# 使用 .NET 10.0 SDK 镜像来构建应用
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["MyWebApp.csproj", "./"]
RUN dotnet restore "./MyWebApp.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./MyWebApp.csproj" -c $BUILD_CONFIGURATION -o /app/build

# 发布阶段：生成发布版本
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./MyWebApp.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# 最终阶段：创建运行时镜像
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyWebApp.dll"]