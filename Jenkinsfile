pipeline {
    agent any

    environment {
        SONAR_AUTH_TOKEN = credentials('jenkins-token') // Ton secret Jenkins
    }

    stages {
        // 1️⃣ Récupération du code source
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    changelog: false,
                    credentialsId: '', // si repo privé, sinon vide
                    url: 'https://github.com/nourhammmemi/devops-nour.git'
            }
        }

        // 2️⃣ Compilation Maven
        stage('Maven Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        // 3️⃣ Analyse SonarQube
        stage('SonarQube Analysis') {
            steps {
                script {
                    try {
                        withSonarQubeEnv('sonarqube') {
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

        // 4️⃣ Quality Gate SonarQube
        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline blocked: SonarQube Quality Gate failed (${qg.status})"
                        }
                    }
                }
            }
        }

        // 5️⃣ Scans de sécurité (Parallèle avec failFast)
        stage('Security Scans') {
            parallel failFast: true,
            stages: [
                stage('SCA - Trivy FS') {
                    steps {
                        script {
                            echo "Running Trivy filesystem scan..."
                            def status = sh(script: 'bash ci/scripts/run_trivy_fs.sh', returnStatus: true)
                            if (status != 0) {
                                error "Trivy FS scan failed"
                            }
                        }
                    }
                },
                stage('Secrets Scan - Gitleaks') {
                    steps {
                        script {
                            echo "Running Gitleaks secrets scan..."
                            def status = sh(script: 'bash ci/scripts/run_gitleaks.sh', returnStatus: true)
                            if (status != 0) {
                                error "Gitleaks scan failed"
                            }
                        }
                    }
                },
                stage('Docker Build & Scan') {
                    steps {
                        script {
                            if (fileExists('Dockerfile')) {
                                echo "Building Docker image..."
                                sh 'docker build -t devops-nour .'
                                echo "Scanning Docker image with Trivy..."
                                def status = sh(
                                    script: 'docker run --rm aquasec/trivy:latest image --exit-code 1 --severity CRITICAL devops-nour',
                                    returnStatus: true
                                )
                                if (status != 0) {
                                    error "Docker image scan failed"
                                }
                            } else {
                                echo "Dockerfile not found, skipping Docker build & scan"
                            }
                        }
                    }
                }
            ]
        }
    }

    post {
        always {
            echo "Pipeline finished. Build status: ${currentBuild.result ?: 'SUCCESS'}"
        }
    }
}


