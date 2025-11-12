pipeline {
    agent any

    stages {
        stage('Checkout') {
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
                script {
                    try {
                        withSonarQubeEnv('sonarqube') {
                            sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=devops-nour -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
                        }
                    } catch (err) {
                        echo "SonarQube step failed. Marking build as UNSTABLE."
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }

        stage('Security Scans (Parallel)') {
            parallel {
                stage('SCA - Dependency Scan (Trivy)') {
                    steps {
                        script {
                            try {
                                sh 'bash ci/scripts/run_trivy_fs.sh'
                            } catch (err) {
                                echo "Trivy SCA scan failed. Marking build as UNSTABLE."
                                currentBuild.result = 'UNSTABLE'
                            }
                        }
                    }
                }

                stage('Docker Build and Scan') {
                    steps {
                        script {
                            try {
                                def dockerfile = "${pwd()}/Dockerfile"
                                if (fileExists(dockerfile)) {
                                    def imageName = "devops-nour:latest"
                                    sh "docker build -t ${imageName} ."
                                    sh "bash ci/scripts/run_trivy_image.sh ${imageName}"
                                } else {
                                    echo "Dockerfile not found. Skipping Docker build."
                                }
                            } catch (err) {
                                echo "Docker build/scan failed. Marking build as UNSTABLE."
                                currentBuild.result = 'UNSTABLE'
                            }
                        }
                    }
                }

                stage('Secrets Scan (Gitleaks)') {
                    steps {
                        script {
                            try {
                                sh 'bash ci/scripts/run_gitleaks.sh'
                            } catch (err) {
                                echo "Gitleaks scan failed. Marking build as UNSTABLE."
                                currentBuild.result = 'UNSTABLE'
                            }
                        }
                    }
                }

                stage('DAST Scan (OWASP ZAP)') {
                    steps {
                        script {
                            try {
                                sh 'bash ci/scripts/run_zap_dast.sh http://localhost:8080'
                            } catch (err) {
                                echo "DAST scan failed. Marking build as UNSTABLE."
                                currentBuild.result = 'UNSTABLE'
                            }
                        }
                    }
                }
            }
        }

        stage('Summary') {
            steps {
                script {
                    if (currentBuild.result == 'UNSTABLE') {
                        echo "Pipeline finished with UNSTABLE status. Some security checks failed."
                    } else {
                        echo "Pipeline finished SUCCESSFULLY. All builds and scans passed."
                    }
                }
            }
        }
    }
}

