FROM maven:3.8.6-openjdk-17 AS build

# Copier pom.xml et télécharger uniquement les dépendances d'abord
COPY pom.xml /app/
WORKDIR /app
RUN mvn dependency:go-offline -B

# Copier tout le code et build
COPY src /app/src
RUN mvn clean package -DskipTests

# Phase finale avec seulement le JAR
FROM openjdk:17-jdk-slim
COPY --from=build /app/target/timesheet-devops-1.0.jar /app/timesheet-devops-1.0.jar
ENTRYPOINT ["java","-jar","/app/timesheet-devops-1.0.jar"]


