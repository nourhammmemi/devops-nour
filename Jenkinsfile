#!/usr/bin/env groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "devops-nour:latest"
    }

    stages {
        stage('GIT') {
            steps {
                echo "📦 Clonage du dépôt Git..."
                git branch: 'main',
                    changelog: false,
                    credentialsId: 'jenkins-github-https-cred',
                    url: 'https://github.com/nourhammmemi/devops-nour.git'
            }
        }

        stage('MAVEN Build') {
            steps {
                echo "🔧 Compilation du projet Maven..."
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Unit Tests') {
            steps {
                echo "🧪 Exécution des tests unitaires..."
                sh 'mvn test'
            }
        }

       stage('Docker Build') {
    steps {
        script {
            if (fileExists('Dockerfile')) {
                sh 'docker build -t devops-nour .'
            } else {
                echo "Dockerfile not found, skipping Docker build"
            }
        }
    }

        stage('Security Scan') {
            parallel {
                stage('Trivy Image Scan') {
                    steps {
                        echo "🔍 Analyse de l’image Docker avec Trivy..."
                        sh """
                            #!/bin/bash
                            set -e
                            IMAGE_NAME=${IMAGE_NAME}
                            echo "Scanning Docker image \$IMAGE_NAME with Trivy..."
                            docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                            -v \$(pwd):/root/.cache/ aquasec/trivy:latest image --no-progress --format json \
                            -o trivy-image-report.json "\$IMAGE_NAME" || true
                        """
                    }
                }

                stage('OWASP Dependency Check') {
                    steps {
                        echo "🧩 Vérification des dépendances avec OWASP..."
                        sh """
                            mkdir -p dependency-check
                            docker run --rm -v \$(pwd):/src \
                            owasp/dependency-check:latest \
                            --scan /src --format "HTML" --out /src/dependency-check-report.html || true
                        """
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_SCANNER_OPTS = '-Dsonar.projectKey=devops-nour'
            }
            steps {
                echo "📊 Analyse de la qualité du code avec SonarQube..."
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Docker Push') {
            steps {
                echo "📤 Envoi de l’image Docker vers le registre..."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag ${IMAGE_NAME} $DOCKER_USER/${IMAGE_NAME}
                        docker push $DOCKER_USER/${IMAGE_NAME}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline exécuté avec succès !"
        }
        failure {
            echo "❌ Le pipeline a échoué."
        }
        always {
            echo "📦 Nettoyage..."
            sh 'docker system prune -f'
        }
    }
}





