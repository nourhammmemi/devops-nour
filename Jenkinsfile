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
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=devops-nour -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
                }
            }
        }

        stage('SCA - Dependency Scan (Trivy)') {
            steps {
                script {
                    try {
                        sh 'bash ci/scripts/run_trivy_fs.sh'
                    } catch (err) {
                        echo "Trivy scan failed, marking build as UNSTABLE"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }

        stage('Docker Build and Scan') {
            steps {
                script {
                    def dockerfile = "${pwd()}/Dockerfile"
                    if (fileExists(dockerfile)) {
                        def imageName = "devops-nour:latest"
                        sh "docker build -t ${imageName} ."
                        sh "bash ci/scripts/run_trivy_image.sh ${imageName}"
                    } else {
                        echo "Dockerfile not found at ${dockerfile}. Skipping Docker build."
                    }
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
                script {
                    try {
                        sh 'bash ci/scripts/run_zap_dast.sh http://localhost:8080'
                    } catch (err) {
                        echo "DAST scan failed, marking build as UNSTABLE"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
    }
}

