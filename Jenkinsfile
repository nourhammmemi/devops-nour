pipeline {
    agent any

    environment {
        SONAR_AUTH_TOKEN = credentials('jenkins-token') // Ton token Jenkins pour SonarQube
    }

    stages {
        // 1️⃣ Récupération du code source
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    changelog: false,
                    credentialsId: '', // <-- Mettre l'ID si repo privé, sinon laisser vide
                    url: 'https://github.com/nourhammmemi/devops-nour.git'
            }
        }

        // 2️⃣ Compilation Maven
        stage('Maven Build') {
            steps {
                sh 'mvn clean package' // 'package' plus rapide que 'verify'
            }
        }

        // 3️⃣ Analyse SonarQube
        stage('SonarQube Analysis') {
            steps {
                script {
                    try {
                        withSonarQubeEnv('sonarqube') { // Vérifier que le nom correspond au serveur Jenkins
                            sh """
                                mvn sonar:sonar \
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

        // 5️⃣ Scans de sécurité (Parallèle)
        stage('Security Scans (Parallel)') {
            parallel failFast: true { // FailFast = arrête toutes les branches si une échoue
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
                                sh 'docker run --rm aquasec/trivy:latest image --exit-code 1 --severity CRITICAL devops-nour'
                            } else {
                                echo "Dockerfile not found, skipping Docker build & scan"
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
            cleanWs() // Nettoie l'espace de travail après chaque run
        }
    }
}
