pipeline {
    agent any

    stages {
         steps {
                // Remplacement de la commande 'git' par checkout pour utiliser Git du système
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/nourhammmemi/devops-nour.git',
                        credentialsId: 'jenkins-github-https-cred'
                    ]]
                ])
            }

        stage('MAVEN Build') {
            steps {
                // Compile le projet sans exécuter les tests
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

        // -----------------------------
        // SCA - Analyse des dépendances
        // -----------------------------
        stage('SCA - Dependency Scan (Trivy)') {
            steps {
                sh 'bash ci/scripts/run_trivy_fs.sh'
            }
        }

        // -----------------------------
        // Docker Build + Scan
        // -----------------------------
        stage('Docker Build and Scan') {
            steps {
                script {
                    def imageName = "devops-nour:latest"
                    sh "docker build -t ${imageName} ."
                    sh "bash ci/scripts/run_trivy_image.sh ${imageName}"
                }
            }
        }

        // -----------------------------
        // Secrets Scan avec Gitleaks
        // -----------------------------
        stage('Secrets Scan (Gitleaks)') {
            steps {
                sh 'bash ci/scripts/run_gitleaks.sh'
            }
        }

        // -----------------------------
        // DAST Scan avec OWASP ZAP
        // -----------------------------
        stage('DAST Scan (OWASP ZAP)') {
            steps {
                sh 'bash ci/scripts/run_zap_dast.sh http://localhost:8080' // adapte l'URL si nécessaire
            }
        }
    }

    // ✅ Pas d'accolade supplémentaire ici
}

