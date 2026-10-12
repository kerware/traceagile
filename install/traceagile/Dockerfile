# TraceAgile en conteneur (docs/installation.md §6) : image construite à partir du jar distribuable
# (API, interface et guide). Contexte : ce dossier, qui contient traceagile-api.jar.
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# uid fixe : le service installation-demo lui donne les pièces jointes de la démo
RUN addgroup -S -g 10001 app && adduser -S -u 10001 -G app app \
 && mkdir -p /data/pieces-jointes && chown app:app /data/pieces-jointes
COPY traceagile-api.jar app.jar
USER app
EXPOSE 8085
HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --retries=10 \
  CMD wget -qO- http://localhost:8085/actuator/health | grep -q UP || exit 1
ENTRYPOINT ["sh", "-c", "exec java -XX:MaxRAMPercentage=75 $JAVA_OPTS -jar app.jar"]
