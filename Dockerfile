# Étape 1 : Builder avec Maven
FROM maven:3.9.3-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Étape 2 : Image runtime
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=builder /app/target/timesheet-devops-1.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

