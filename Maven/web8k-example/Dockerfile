# This is a docker make file for building this Maven app
# and putting it into a docker image...

# This is not really needed, but it shows how to do it...
FROM maven:3.8-jdk-11 as imagebuilder

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn package 

FROM adoptopenjdk/openjdk11:alpine-slim

RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

ARG JAR_FILE=/app/target/web8k-example-1.0-SNAPSHOT.jar
COPY --from=imagebuilder ${JAR_FILE} /web8k-example.jar

CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/web8k-example.jar","application.Webk8App"]
EXPOSE 8080
EXPOSE 80
