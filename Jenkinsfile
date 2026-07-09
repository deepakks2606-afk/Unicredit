pipeline {
    agent any
    tools {
        maven 'Maven 3'   // Configure this name in Jenkins > Global Tool Configuration
        jdk 'JDK 21'      // Configure this name in Jenkins > Global Tool Configuration
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                bat 'mvn -B clean compile'   // use 'sh' instead of 'bat' if agent is Linux
            }
        }
        stage('Test') {
            steps {
                bat 'mvn -B test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Package WAR') {
            steps {
                bat 'mvn -B package -DskipTests'
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.war', fingerprint: true
            }
        }
        stage('Upload to JFrog') {
            steps {
                jf 'rt upload target/sample-war-app.war war-releases-local/com/example/sample-war-app/%BUILD_NUMBER%/ --server-id=jfrog-server'
            }
        }
        // Optional: deploy to a Tomcat server. Requires the
        // "Deploy to container" Jenkins plugin and a configured Tomcat manager user.
        // stage('Deploy') {
        //     steps {
        //         deploy adapters: [tomcat9(credentialsId: 'tomcat-creds', url: 'http://localhost:8081')],
        //                war: 'target/*.war'
        //     }
        // }
    }
    post {
        success {
            echo 'WAR build succeeded!'
        }
        failure {
            echo 'Build failed — check the logs above.'
        }
    }
}