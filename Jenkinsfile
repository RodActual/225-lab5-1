pipeline {
    agent any 

    environment {
        DOCKER_CREDENTIALS_ID = 'roseaw-dockerhub'  
        DOCKER_IMAGE = 'cithit/rodrig99'                                   
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        GITHUB_URL = 'https://github.com/RodActual/225-lab5-1.git'     
        KUBECONFIG = credentials('rodrig99-225')                         
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout([$class: 'GitSCM', branches: [[name: '*/main']],
                          userRemoteConfigs: [[url: "${GITHUB_URL}"]]])
            }
        }

        stage('Static Code Testing') {
            parallel {
                stage('Security Scan') {
                    steps {
                        echo 'Running Bandit...'
                        sh 'python3 -m pip install --user bandit'
                        sh 'python3 -m bandit -r . -ll'
                    }
                }
                stage('Linting') {
                    steps {
                        echo 'Running Flake8...'
                        sh 'python3 -m pip install --user flake8'
                        sh 'python3 -m flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'sed -i "s/BUILD_ID_PLACEHOLDER/${BUILD_NUMBER}/g" templates/index.html'
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_CREDENTIALS_ID}") {
                        docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                    }
                }
            }
        }

        stage('Push & Deploy') {
            steps {
                script {
                    // Push the newly built image
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                    
                    // Update the deployment-dev.yaml to use the new image tag
                    sh "sed -i 's|${DOCKER_IMAGE}:latest|${DOCKER_IMAGE}:${IMAGE_TAG}|' deployment-dev.yaml"
                    
                    // Deploy using the native method from your previous lab
                    def kubeConfig = readFile(KUBECONFIG)
                    sh "kubectl apply -f deployment-dev.yaml"
                    sh "kubectl rollout status deployment/flask-deployment"
                }
            }
        }
    }

    post {
        always {
            // Clean up Docker images locally to save space on the Jenkins agent
            sh "docker rmi ${DOCKER_IMAGE}:${IMAGE_TAG} || true"
        }
    }
}
