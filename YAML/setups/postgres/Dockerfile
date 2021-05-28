# Creating a PSQL client only image
FROM alpine

RUN apk update
RUN apk add postgresql-client
RUN apk add openssh

CMD ["/bin/sh","-c","while true; do sleep 1; done;"]