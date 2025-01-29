@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml docker()
            showRawYaml false
        }
    }

    stages {
        stage('Build Docker Image') {
            steps {
                container('docker') {
                    
                        sh """
                        docker build -t owasp-zap:latest .
                        """
                }
            }
        }

        stage('Push') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'docker_hub_up', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh '''
                        echo $PASSWORD | docker login -u $USERNAME --password-stdin
                        docker tag owasp-dep:latest naivedh/owasp-zap:latest
                        docker push naivedh/owasp-zap:latest
                        '''
                    }
                }
            }
        }
    }
}
