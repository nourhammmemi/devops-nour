pipeline {
    agent any

    environment {
        SONARQUBE_NAME = 'sonarqube'   // Nom exact de ton installation SonarQube
        SONAR_HOST_URL = 'http://localhost:9000'
        DOCKER_IMAGE_NAME = "devops-nour:latest"
        APP_URL = "http://localhost:8082" // port où Spring Boot tourne
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
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
                        // Utiliser withCredentials pour le token
                        withCredentials([string(credentialsId: 'jenkins-token', variable: 'SONAR_AUTH_TOKEN')]) {
                            withSonarQubeEnv(SONARQUBE_NAME) {
                                sh "mvn verify sonar:sonar -Dsonar.projectKey=devops-nour -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_AUTH_TOKEN}"
                            }
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
                        script {
                            try {
                                sh 'bash ci/scripts/run_trivy_fs.sh'
                            } catch (err) {
                                echo "Trivy filesystem scan failed, marking build as UNSTABLE"
                                currentBuild.result = 'UNSTABLE'
                            }
                        }
                    }
                }

                stage('Docker Build & Scan') {
                    steps {
                        script {
                            def dockerfilePath = "${pwd()}/Dockerfile"
                            if (fileExists(dockerfilePath)) {
                                sh "docker build -t ${DOCKER_IMAGE_NAME} ."
                                sh "bash ci/scripts/run_trivy_image.sh ${DOCKER_IMAGE_NAME}"
                            } else {
                                echo "Dockerfile not found at ${dockerfilePath}, skipping Docker build"
                            }
                        }
                    }
                }

                stage('Secrets Scan - Gitleaks') {
                    steps {
                        script {
                            try {
                                sh 'bash ci/scripts/run_gitleaks.sh'
                            } catch (err) {
                                echo "Gitleaks scan failed, marking build as UNSTABLE"
                                currentBuild.result = 'UNSTABLE'
                            }
                        }
                    }
                }

                stage('DAST - OWASP ZAP') {
                    steps {
                        script {
                            try {
                                sh 'docker pull owasp/zap2docker-stable || true'
                                sh "bash ci/scripts/run_zap_dast.sh ${APP_URL}"
                            } catch (err) {
                                echo "DAST scan failed, marking build as UNSTABLE"
                                currentBuild.result = 'UNSTABLE'
                            }
                        }
                    }
                }
            }
        }

        stage('Pipeline Summary') {
            steps {
                script {
                    echo "Pipeline finished. Current build status: ${currentBuild.result ?: 'SUCCESS'}"
                }
            }
        }
    }
}
