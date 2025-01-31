@Library('k8s-shared-lib') _
pipeline {
    agent any
    environment {
        IMAGE_NAME = "owasp-zap"
        IMAGE_TAG = "latest"
        DOCKER_HUB_REPO = "naivedh/owasp-zap"
        DOCKER_CREDENTIALS = "docker_hub_up"
    }

    stages {
        
        stage('Build Docker Image') {
            agent {
                kubernetes {
                    yaml docker('docker-build', 'docker:latest')
                    showRawYaml false
                }
            }
            steps {
                container('docker-build') {
                    script {
                        echo "Building Docker image..."
                        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    }
                }
                // Stash the image outside the script block
                stash name: 'image', includes: "${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Trivy Scan') {
            agent {
                kubernetes {
                    yaml pod('trivy', 'aquasec/trivy:latest')
                    showRawYaml false
                }
            }
            steps {
                container('trivy') {
                    script {
                        unstash 'image'
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

        stage('Push Docker Image') {
            agent {
                kubernetes {
                    yaml docker('docker-push', 'docker:latest')
                    showRawYaml false
                }
            }
            steps {
                container('docker-push') {
                    script {
                        unstash 'image'
                        withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                            echo "Logging into Docker Hub..."
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
}
