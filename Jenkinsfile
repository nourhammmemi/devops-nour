#!/usr/bin/env groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "devops-nour:latest"
        JAR_FILE = "target/timesheet-devops-1.0.jar"
    }

    options {
        timeout(time: 60, unit: 'MINUTES')
        disableConcurrentBuilds()
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
                
                script {
                    // Vérifier que le JAR existe
                    if (!fileExists(env.JAR_FILE)) {
                        error "❌ JAR non trouvé : ${env.JAR_FILE}. Vérifie la compilation Maven."
                    }
                }
            }
        }

        stage('Unit Tests') {
            steps {
                echo "🧪 Exécution des tests unitaires..."
                sh 'mvn test'
            }
        }

        stage('Security Scan') {
            parallel {
                stage('Trivy Image Scan') {
                    steps {
                        echo "🔍 Analyse de l’image Docker avec Trivy..."
                        sh """
                            timeout 300s docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                            -v \$(pwd):/root/.cache/ aquasec/trivy:latest image --no-progress --format json \
                            -o trivy-image-report.json ${IMAGE_NAME} || true
                        """
                    }
                }

                stage('OWASP Dependency Check') {
                    steps {
                        echo "🧩 Vérification des dépendances avec OWASP..."
                        sh """
                            mkdir -p dependency-check
                            timeout 300s docker run --rm -v \$(pwd):/src \
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

        stage('Docker Build & Push') {
            steps {
                echo "🐳 Construction et push de l’image Docker..."
                
                script {
                    if (!fileExists(env.JAR_FILE)) {
                        error "❌ JAR non trouvé pour Docker. Build Maven requis."
                    }
                }

                sh "docker build -t ${IMAGE_NAME} ."

                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag ${IMAGE_NAME} $DOCKER_USER/${IMAGE_NAME}
                        docker push $DOCKER_USER/${IMAGE_NAME}
                        docker logout
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
            echo "📦 Nettoyage des containers et images temporaires..."
            sh 'docker container prune -f || true'
            sh 'docker image prune -f || true'
        }
    }
}

