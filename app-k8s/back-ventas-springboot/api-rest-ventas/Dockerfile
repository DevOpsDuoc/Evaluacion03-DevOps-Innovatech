# Fase 1: Compilación de Java con Maven
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copiar el código fuente y el archivo pom.xml
COPY pom.xml .
COPY src ./src
COPY mvnw .
COPY .mvn ./.mvn

# Compilar omitiendo los tests para evitar fallas por falta de Base de Datos en el pipeline
RUN mvn clean package -DskipTests

# Fase 2: Imagen ligera de ejecución (JRE)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copiar el archivo .jar generado en la fase anterior
COPY --from=build /app/target/*.jar app.jar

# El backend de ventas expone el puerto 8080 por defecto
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]