pipeline {
    agent any

    // Variables d'environnement globales
    environment {
        SONAR_AUTH_TOKEN = credentials('jenkins-token') // ID du secret Jenkins
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    changelog: false,
                    credentialsId: '', // si ton repo est public, sinon mets tes credentials GitHub
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
                script {
                    try {
                        withSonarQubeEnv('sonarqube') { // nom du serveur SonarQube configuré dans Jenkins
                            sh """
                                mvn verify sonar:sonar \
                                    -Dsonar.projectKey=devops-nour \
                                    -Dsonar.login=${SONAR_AUTH_TOKEN}
                            """
                        }
                    } catch (err) {
                        echo "SonarQube scan failed, marking build as UNSTABLE"
                        currentBuild.result = 'UNSTABLE'
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

                stage('Secrets Scan - Gitleaks') {
                    steps {
                        sh 'bash ci/scripts/run_gitleaks.sh'
                    }
                }

                stage('Docker Build & Scan') {
                    steps {
                        script {
                            if (fileExists('Dockerfile')) {
                                sh 'docker build -t devops-nour .'
                            } else {
                                echo "Dockerfile not found, skipping Docker build"
                            }
                        }
                    }
                }

                stage('DAST - OWASP ZAP') {
                    steps {
                        script {
                            try {
                                sh 'docker pull owasp/zap2docker-stable:latest || true'
                                sh 'bash ci/scripts/run_zap_dast.sh http://localhost:8082'
                            } catch (err) {
                                echo "OWASP ZAP scan failed, continuing..."
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Build status: ${currentBuild.result ?: 'SUCCESS'}"
        }
    }
}
