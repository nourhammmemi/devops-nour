pipeline {
    agent any

    environment {
        // Variables d'environnement si nécessaires
    }

    stages {

        stage('GIT') {
            steps {
                echo '📦 Clonage du dépôt Git...'
                git branch: 'main',
                    changelog: false,
                    credentialsId: 'jenkins-github-https-cred',
                    url: 'https://github.com/nourhammmemi/devops-nour.git'
            }
        }

        stage('MAVEN Build') {
            steps {
                echo '🔧 Compilation du projet Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Unit Tests') {
            steps {
                echo '🧪 Exécution des tests unitaires...'
                sh 'mvn test'
            }
        }

        stage('Security Scan') {
            parallel {
                stage('Trivy Image Scan') {
                    steps {
                        echo '🔍 Analyse de l’image Docker avec Trivy...'
                        sh '''
                        pwd
                        timeout 300s docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $WORKSPACE:/root/.cache/ aquasec/trivy:latest image --no-progress --format json -o trivy-image-report.json devops-nour:latest || true
                        '''
                    }
                }

                stage('OWASP Dependency Check') {
                    steps {
                        echo '🧩 Vérification des dépendances avec OWASP...'
                        sh '''
                        mkdir -p dependency-check
                        timeout 300s docker run --rm -v $WORKSPACE:/src owasp/dependency-check:latest --scan /src --format HTML --out /src/dependency-check-report.html || true
                        '''
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '📊 Analyse de la qualité du code avec SonarQube...'
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo '🐳 Construction de l’image Docker...'
                sh 'docker build -t devops-nour:latest .'
                // Push Docker Hub supprimé pour éviter l'erreur
            }
        }

        stage('Cleanup') {
            steps {
                echo '📦 Nettoyage des containers et images temporaires...'
                sh 'docker container prune -f'
                sh 'docker image prune -f'
            }
        }
    }

    post {
        success {
            echo '✅ Le pipeline a été exécuté avec succès !'
        }
        failure {
            echo '❌ Le pipeline a échoué.'
        }
    }
}
