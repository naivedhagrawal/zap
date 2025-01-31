@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml docker()
            showRawYaml false
        }
    }
    environment {
        IMAGE_NAME = "owasp-zap"
        IMAGE_TAG = "latest"
        DOCKER_HUB_REPO = "naivedh/owasp-zap"
        DOCKER_CREDENTIALS = "docker_hub_up"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                container('docker') {
                    
                        sh """
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        """
                }
            }
        }
        
        stage('Push') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh '''
                        echo $PASSWORD | docker login -u $USERNAME --password-stdin
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_REPO}:${IMAGE_TAG}
                        docker push ${DOCKER_HUB_REPO}:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }
    }
}
