# Use an official Tomcat image with Java 21
FROM tomcat:10.1-jdk21

# Remove default ROOT app (optional, avoids clutter)
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the built WAR into Tomcat's webapps folder
# Deploys as the root context (accessible at http://host:8080/)
COPY target/sample-war-app.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
