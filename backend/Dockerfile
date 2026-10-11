# Image unique de build pour les modules Spring Boot ; cibles « api » et « mock-execution-server ».
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
COPY traceagile-domain/pom.xml traceagile-domain/
COPY traceagile-application/pom.xml traceagile-application/
COPY traceagile-infrastructure/pom.xml traceagile-infrastructure/
COPY traceagile-api/pom.xml traceagile-api/
COPY mock-execution-server/pom.xml mock-execution-server/
COPY execution-server/pom.xml execution-server/
RUN mvn -B -q dependency:go-offline -DexcludeReactor=true || true
COPY . .
# -DskipUi : l'interface du serveur d'exécution n'est construite que par son image (execution-server/Dockerfile)
RUN mvn -B -q package -DskipTests -DskipUi

FROM eclipse-temurin:21-jre-alpine AS api
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app && mkdir -p /data/attachments && chown app:app /data/attachments
COPY --from=build /workspace/traceagile-api/target/traceagile-api.jar app.jar
USER app
EXPOSE 8085
HEALTHCHECK --interval=10s --timeout=3s --start-period=40s --retries=10 \
  CMD wget -qO- http://localhost:8085/actuator/health | grep -q UP || exit 1
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]

FROM eclipse-temurin:21-jre-alpine AS mock-execution-server
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /workspace/mock-execution-server/target/mock-execution-server.jar app.jar
USER app
EXPOSE 8090
HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=10 \
  CMD wget -qO- http://localhost:8090/api/v1/health | grep -q UP || exit 1
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
