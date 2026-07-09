# sample-war-app

A minimal Java Servlet web app packaged as a WAR file via Maven, ready for Jenkins CI/CD and Tomcat deployment.

## Local build

```bash
mvn clean package
```

This produces `target/sample-war-app.war`.

## Run tests only

```bash
mvn test
```

## Deploy to Tomcat manually

1. Copy `target/sample-war-app.war` into `<TOMCAT_HOME>/webapps/`.
2. Start Tomcat.
3. Visit `http://localhost:8080/sample-war-app/` (or `/sample-war-app/hello` for the servlet directly).

## Jenkins setup

1. Install the **Maven Integration**, **Pipeline**, and (optionally) **Deploy to container** plugins.
2. **Manage Jenkins > Tools**:
   - Add a JDK installation named `JDK 21`.
   - Add a Maven installation named `Maven 3`.
   (Or edit the names in the `Jenkinsfile` to match your existing tool configs.)
3. Create a new **Pipeline** job pointing at this repo — Jenkins will auto-detect the `Jenkinsfile`.
4. Pipeline stages: Checkout → Build → Test → Package WAR → Archive.
5. To auto-deploy to a Tomcat server, uncomment the `Deploy` stage in the `Jenkinsfile` and configure
   Tomcat manager credentials in Jenkins first.

> Note: The `Jenkinsfile` uses `bat` steps (Windows agents). If your Jenkins agent runs Linux, replace `bat` with `sh`.
