pipeline {
    agent any

    stages {
        stage('GIT') {
            steps {
                git branch: 'main',
                    changelog: false,
                    credentialsId: 'jenkins-github-https-cred',
                    url: 'https://github.com/nourhammmemi/devops-nour.git'
            }
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
    }
 

}
