FROM adoptopenjdk/openjdk11:alpine-slim
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY ${JAR_FILE} /web8k-example.jar

CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/web8k-example.jar","application.Webk8App"]
EXPOSE 8080
EXPOSE 80
