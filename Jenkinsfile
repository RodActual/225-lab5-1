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
                        sh 'pip install bandit && bandit -r . -ll'
                    }
                }
                stage('Linting') {
                    steps {
                        echo 'Running Flake8...'
                        sh 'pip install flake8 && flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Criteria: Pipeline Contains Docker Build
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_CREDENTIALS_ID}") {
                        docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                    }
                }
            }
        }

        stage('Push & Deploy') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                    
                    // Criteria: Deployed Project Demonstrated
                    // Using 'sed' to inject the specific build tag into the YAML
                    sh "sed -i 's|${DOCKER_IMAGE}:latest|${DOCKER_IMAGE}:${IMAGE_TAG}|' deployment-dev.yaml"
                    
                    withKubeConfig([credentialsId: 'rodrig99-225']) {
                        sh "kubectl apply -f deployment-dev.yaml"
                        sh "kubectl rollout status deployment/flask-deployment"
                    }
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
