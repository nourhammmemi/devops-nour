pipeline {
    agent any

    stages {
        stage('GIT') {
            steps {
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[url: 'https://github.com/nourhammmemi/devops-nour.git']]])
            }
        }

        stage('MAVEN Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('SONARQUBE') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh "mvn clean verify sonar:sonar -Dsonar.projectKey=devops-nour -Dsonar.host.url=http://192.168.50.4:9000/ -Dsonar.login=$SONAR_AUTH_TOKEN"
                }
            }
        }

        stage('SCA - Dependency Scan (Trivy)') {
            steps {
                sh 'bash ci/scripts/run_trivy_fs.sh'
            }
        }

        stage('Docker Build and Scan') {
            steps {
                script {
                    def imageName = "devops-nour:latest"
                    sh "docker build -t ${imageName} ."
                    sh "bash ci/scripts/run_trivy_image.sh ${imageName}"
                }
            }
        }

        stage('Secrets Scan (Gitleaks)') {
            steps {
                sh 'bash ci/scripts/run_gitleaks.sh'
            }
        }

        stage('DAST Scan (OWASP ZAP)') {
            steps {
                sh 'bash ci/scripts/run_zap_dast.sh http://localhost:8080'
            }
        }
    }
}
