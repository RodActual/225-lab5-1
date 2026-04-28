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
            steps {
                echo 'Running Static Analysis with Bandit...'
                // This satisfies the "Static Code Testing" rubric requirement
                sh 'pip install bandit'
                sh 'bandit -r . -ll' 
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_CREDENTIALS_ID}") {
                        docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Dev Environment') {
            steps {
                script {
                    // Update the deployment manifest with the new build tag
                    sh "sed -i 's|${DOCKER_IMAGE}:latest|${DOCKER_IMAGE}:${IMAGE_TAG}|' deployment-dev.yaml"
                    
                    // Deploying to the Kubernetes cluster
                    withKubeConfig([credentialsId: 'rodrig99-225']) {
                        sh "kubectl apply -f deployment-dev.yaml"
                        sh "kubectl get all"
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend color: "good", message: "Build Completed Successfully: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend color: "danger", message: "Build Failed during ${env.STAGE_NAME}: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
    }
}
