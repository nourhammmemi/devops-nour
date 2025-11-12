pipeline {
    agent any

    environment {
        // Pas besoin de mettre SONAR_HOST_URL ici, il sera injecté par withSonarQubeEnv
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    credentialsId: 'jenkins-github-https-cred',
                    url: 'https://github.com/nourhammmemi/devops-nour.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'jenkins-token', variable: 'SONAR_AUTH_TOKEN')]) {
                    // 'sonarqube' doit correspondre exactement au nom de ton serveur dans Jenkins
                    withSonarQubeEnv('sonarqube') {
                        sh """
                        mvn verify sonar:sonar \
                            -Dsonar.projectKey=devops-nour \
                            -Dsonar.host.url=\${SONAR_HOST_URL} \
                            -Dsonar.login=\${SONAR_AUTH_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Security Scans (Parallel)') {
            parallel {
                stage('SCA - Trivy FS') {
                    steps {
                        sh 'bash ci/scripts/run_trivy_fs.sh'
                    }
                }
                stage('Docker Build & Scan') {
                    steps {
                        sh 'echo "Dockerfile not found, skipping Docker build"'
                    }
                }
                stage('Secrets Scan - Gitleaks') {
                    steps {
                        sh 'bash ci/scripts/run_gitleaks.sh'
                    }
                }
                stage('DAST - OWASP ZAP') {
                    steps {
                        sh 'bash ci/scripts/run_zap_dast.sh http://localhost:8082 || true'
                    }
                }
            }
        }

        stage('Pipeline Summary') {
            steps {
                script {
                    echo "Pipeline finished. Current build status: ${currentBuild.currentResult}"
                }
            }
        }
    }
}
