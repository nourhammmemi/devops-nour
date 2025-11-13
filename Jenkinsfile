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

        // 5️⃣ Scans de sécurité (Parallèle)
        stage('Security Scans (Parallel)') {
            failFast true  // Arrête toutes les branches si une échoue
            parallel (
                'SCA - Trivy FS': {
                    sh 'bash ci/scripts/run_trivy_fs.sh'
                },
                'Secrets Scan - Gitleaks': {
                    sh 'bash ci/scripts/run_gitleaks.sh'
                },
                'Docker Build & Scan': {
                    script {
                        if (fileExists('Dockerfile')) {
                            sh 'docker build -t devops-nour .'
                            sh 'docker run --rm aquasec/trivy:latest image --exit-code 1 --severity CRITICAL devops-nour'
                        } else {
                            echo "Dockerfile not found, skipping Docker build & scan"
                        }
                    }
                }
            )
        }
    }

    post {
        always {
            echo "Pipeline finished. Build status: ${currentBuild.result ?: 'SUCCESS'}"
        }
        success {
            echo "Pipeline completed successfully ✅"
        }
        unstable {
            echo "Pipeline completed but marked UNSTABLE ⚠️"
        }
        failure {
            echo "Pipeline failed ❌"
        }
    }
}



