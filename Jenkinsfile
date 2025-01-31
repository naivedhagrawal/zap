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
        stage('Trivy Install') {
            steps {
                container('docker') {
                    sh """
                    sudo apt-get update -y || sudo yum update -y
                    sudo apt-get install -y curl || sudo yum install -y curl
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
                    trivy --version
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    
                        sh """
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        """
                }
            }
        }
        stage('Trivy Scan') {
            steps {
                container('docker') {
                    script {
                        echo "Scanning image with Trivy..."
                        def exitCode = sh(
                            script: "trivy image --exit-code 1 --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}",
                            returnStatus: true
                        )
                        if (exitCode != 0) {
                            error "Vulnerabilities found! Fix them before pushing."
                        }
                    }
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
