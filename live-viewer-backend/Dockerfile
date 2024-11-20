FROM gradle:8.10.2-jdk21 AS build
WORKDIR /home/gradle/project
COPY build.gradle settings.gradle ./
COPY src ./src
RUN gradle build --no-daemon

FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app
COPY --from=build /home/gradle/project/build/libs/live-viewer-backend-0.0.1-SNAPSHOT.jar app.jar
ENV KAFKA_BOOTSTRAP_SERVERS=kafka:9093
ENTRYPOINT ["java", "-jar", "app.jar"]
