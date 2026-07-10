pipeline {
    agent any

    tools {
        maven 'Maven 3'   // Configure this name in Jenkins > Global Tool Configuration
        jdk 'JDK 21'      // Configure this name in Jenkins > Global Tool Configuration
    }

    environment {
        DOCKER_REGISTRY   = 'trialgv5wrb.jfrog.io'
        DOCKER_REPO       = 'docker-local'
        IMAGE_NAME        = 'sample-war-app'
        GCP_VM_USER       = 'deepakks2606'
        GCP_VM_IP         = '136.109.254.31'
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

        stage('Package WAR (internal only)') {
            steps {
                bat 'mvn -B package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                bat "docker build -t %DOCKER_REGISTRY%/%DOCKER_REPO%/%IMAGE_NAME%:%BUILD_NUMBER% ."
                bat "docker tag %DOCKER_REGISTRY%/%DOCKER_REPO%/%IMAGE_NAME%:%BUILD_NUMBER% %DOCKER_REGISTRY%/%DOCKER_REPO%/%IMAGE_NAME%:latest"
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'jfrog-creds', usernameVariable: 'JFROG_USER', passwordVariable: 'JFROG_PASS')]) {
                    bat "docker login %DOCKER_REGISTRY% -u %JFROG_USER% -p %JFROG_PASS%"
                    bat "docker push %DOCKER_REGISTRY%/%DOCKER_REPO%/%IMAGE_NAME%:%BUILD_NUMBER%"
                    bat "docker push %DOCKER_REGISTRY%/%DOCKER_REPO%/%IMAGE_NAME%:latest"
                }
            }
        }

        stage('Deploy to GCP') {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'gcp-vm-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER'),
                    usernamePassword(credentialsId: 'jfrog-creds', usernameVariable: 'JFROG_USER', passwordVariable: 'JFROG_PASS')
                ]) {
                    bat """
                        ssh -i "%SSH_KEY%" -o StrictHostKeyChecking=no %SSH_USER%@%GCP_VM_IP% ^
                        "sudo docker login %DOCKER_REGISTRY% -u %JFROG_USER% -p %JFROG_PASS% && ^
                        sudo docker pull %DOCKER_REGISTRY%/%DOCKER_REPO%/%IMAGE_NAME%:latest && ^
                        (sudo docker stop %IMAGE_NAME% || true) && ^
                        (sudo docker rm %IMAGE_NAME% || true) && ^
                        sudo docker run -d -p 80:8080 --name %IMAGE_NAME% %DOCKER_REGISTRY%/%DOCKER_REPO%/%IMAGE_NAME%:latest"
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Full pipeline succeeded: build, test, package, containerize, push, and deploy to GCP!'
        }
        failure {
            echo 'Build failed — check the logs above.'
        }
        always {
            bat "docker logout %DOCKER_REGISTRY%"
        }
    }
}
