####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
#
# Before building the docker image run:
#
# mvn package
#
# Then, build the image with:
#
# docker build -f src/main/docker/Dockerfile -t spring/hello .
#
# Then run the container using:
#
# docker run -i --rm -p 8080:8080 --cpus=1 --memory=1G --name=spring spring/hello
#
###
FROM fabric8/java-alpine-openjdk11-jre
ENV JAVA_OPTIONS="-Xmx64m -Djava.security.egd=file:/dev/./urandom"
ENV AB_OFF=true
COPY target/todo.jar /deployments/app.jar
EXPOSE 8080

# run with user 1001 and be prepared for be running in OpenShift too
RUN adduser -G root --no-create-home --disabled-password 1001 \
  && chown -R 1001 /deployments \
  && chmod -R "g+rwX" /deployments \
  && chown -R 1001:root /deployments
USER 1001

ENTRYPOINT [ "/deployments/run-java.sh" ]