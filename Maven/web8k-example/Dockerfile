# This is a docker make file for building this Maven app
# and putting it into a docker image...

# This is not really needed, but it shows how to do it...
# It also uses a trusted image, although using Github Actions, can achieve the same effect
FROM maven:3.8-jdk-11 as imagebuilder
RUN apt-get update

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn -q -B clean package 

FROM adoptopenjdk/openjdk11:alpine-slim
RUN apk add --upgrade apk-tools && apk upgrade --available

ARG account=spring
RUN addgroup -S ${account} && adduser -S ${account} -G ${account}
USER ${account}:${account}

ARG JAR_FILE=/app/target/web8k-example-1.0-SNAPSHOT.jar
COPY --from=imagebuilder ${JAR_FILE} /web8k-example.jar

CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/web8k-example.jar","application.Webk8App"]
EXPOSE 8080
EXPOSE 80
