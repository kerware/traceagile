# Serveur d'exécution en conteneur (docs/installation.md §8) : image construite à partir du jar distribuable.
# Elle fournit les prérequis (JDK 21, Node.js 22, Python 3, Git) et les bibliothèques système des navigateurs ;
# les outils de test s'installent depuis l'interface dans le volume /opt/tools, jobs et base dans /data.
FROM eclipse-temurin:21-jdk-jammy
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git unzip python3 python3-venv python3-pip xvfb xauth \
      libgtk-3-0 libgbm1 libnss3 libxss1 libasound2 libxtst6 libnotify4 \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && npx -y playwright@1.63.0 install-deps chromium \
 && rm -rf /var/lib/apt/lists/* /root/.npm
RUN git config --system --add safe.directory '*'
RUN useradd --create-home --uid 10001 runner && mkdir -p /data /opt/tools && chown runner:runner /data /opt/tools
WORKDIR /app
COPY execution-server.jar app.jar
USER runner
ENV EXECUTION_SERVER_DATA_DIR=/data \
    EXECUTION_SERVER_TOOLS_DIR=/opt/tools
EXPOSE 8091
HEALTHCHECK --interval=10s --timeout=3s --start-period=40s --retries=10 \
  CMD curl -fs http://localhost:8091/api/v1/health | grep -q UP || exit 1
ENTRYPOINT ["sh", "-c", "exec java -XX:MaxRAMPercentage=50 $JAVA_OPTS -jar app.jar"]
