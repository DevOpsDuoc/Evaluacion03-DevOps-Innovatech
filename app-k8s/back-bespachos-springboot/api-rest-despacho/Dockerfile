# Fase 1: Compilación de Java con Maven
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copiar el código fuente y el archivo pom.xml
COPY pom.xml .
COPY src ./src
COPY mvnw .
COPY .mvn ./.mvn

# Compilar omitiendo los tests
RUN mvn clean package -DskipTests

# Fase 2: Imagen ligera de ejecución (JRE)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copiar el archivo .jar generado en la fase anterior
COPY --from=build /app/target/*.jar app.jar

# IMPORTANTE: Despachos se monta explícitamente en el puerto 8081 según application.properties
EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]