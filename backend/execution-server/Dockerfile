# ADR-0026 serveur d'exécution réel. Contexte de build : backend/ (pom parent).
#   docker build -f execution-server/Dockerfile -t traceagile-execution-server backend
# Le jar autonome (interface incluse) est construit par Maven ; l'image fournit les prérequis
# (JDK 21, Node.js 22, Python 3, Git) et les bibliothèques système des navigateurs. Les outils de test
# s'installent à chaud depuis l'interface dans le volume /opt/tools ; jobs et base dans /data.
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
COPY traceagile-domain/pom.xml traceagile-domain/
COPY traceagile-application/pom.xml traceagile-application/
COPY traceagile-infrastructure/pom.xml traceagile-infrastructure/
COPY traceagile-api/pom.xml traceagile-api/
COPY mock-execution-server/pom.xml mock-execution-server/
COPY execution-server/pom.xml execution-server/
COPY execution-server/ui/package.json execution-server/ui/package-lock.json execution-server/ui/
RUN mvn -B -q -pl execution-server dependency:go-offline || true
COPY execution-server execution-server
RUN mvn -B -q -pl execution-server package -DskipTests

FROM eclipse-temurin:21-jdk-jammy
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git unzip python3 python3-venv python3-pip xvfb xauth \
      libgtk-3-0 libgbm1 libnss3 libxss1 libasound2 libxtst6 libnotify4 \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && npx -y playwright@1.63.0 install-deps chromium \
 && rm -rf /var/lib/apt/lists/* /root/.npm
RUN useradd --create-home --uid 10001 runner && mkdir -p /data /opt/tools && chown runner:runner /data /opt/tools
WORKDIR /app
COPY --from=build /workspace/execution-server/target/execution-server.jar app.jar
USER runner
ENV EXECUTION_SERVER_DATA_DIR=/data \
    EXECUTION_SERVER_TOOLS_DIR=/opt/tools
VOLUME ["/data", "/opt/tools"]
EXPOSE 8091
HEALTHCHECK --interval=10s --timeout=3s --start-period=40s --retries=10 \
  CMD curl -fs http://localhost:8091/api/v1/health | grep -q UP || exit 1
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=50", "-jar", "app.jar"]
