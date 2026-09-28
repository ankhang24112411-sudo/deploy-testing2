FROM eclipse-temurin:17-jdk-jammy AS dependencies
WORKDIR /app

COPY .mvn ./.mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw -B dependency:go-offline

FROM dependencies AS builder
COPY src ./src
RUN ./mvnw -B clean package -DskipTests

FROM eclipse-temurin:17-jdk-jammy AS runtime
WORKDIR /app

COPY --from=builder /app/target/*.war /app/app.jar

EXPOSE 8000

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
