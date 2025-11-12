pipeline {
    agent any

    stages {
        stage('GIT') {
            steps {
                git branch: 'main',
                    changelog: false,
                    credentialsId: 'jenkins-github-https-cred',
                    url: 'https://github.com/nourhammmemi/devops-nour.git'
            }
        }

        stage('MAVEN Build') {
            steps {
                // Compile le projet sans exécuter les tests
                sh 'mvn clean compile'
            }
        }

        stage('SONARQUBE') {
            environment {
                SONAR_HOST_URL = 'http://192.168.50.4:9000/'
                SONAR_AUTH_TOKEN = credentials('sonarqube')
            }
            steps {
                sh 'mvn sonar:sonar -Dsonar.projectKey=devops-nour -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.token=$SONAR_AUTH_TOKEN'
            }
        }
    }
}
