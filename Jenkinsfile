pipeline {
    agent any

    environment {
        IMAGE_NAME = 'sangan132/trend-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Application') {
            steps {
                sh '''
                    test -f Dockerfile
                    test -f nginx.conf
                    test -f dist/index.html
                    echo "Application files verified"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                      -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Test Docker Container') {
            steps {
                sh '''
                    docker rm -f trend-ci-test 2>/dev/null || true

                    docker run -d \
                      --name trend-ci-test \
                      -p 127.0.0.1:18080:80 \
                      ${IMAGE_NAME}:${BUILD_NUMBER}

                    sleep 3

                    curl --fail http://127.0.0.1:18080
                '''
            }
        }
        stage('Push to DockerHub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        set +x

                        export DOCKER_CONFIG=$(mktemp -d)

                        cleanup() {
                            docker logout >/dev/null 2>&1 || true
                            rm -rf "$DOCKER_CONFIG"
                        }

                        trap cleanup EXIT

                        printf '%s' "$DOCKERHUB_TOKEN" | \
                          docker login \
                          --username "$DOCKERHUB_USERNAME" \
                          --password-stdin

                        docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                sh '''
                    export AWS_DEFAULT_REGION=ap-south-2
                    export KUBECONFIG=/var/lib/jenkins/.kube/config

                    echo "Deploying image: ${IMAGE_NAME}:${BUILD_NUMBER}"

                    kubectl set image deployment/trend-app \
                      trend-app=${IMAGE_NAME}:${BUILD_NUMBER}

                    echo "Waiting for deployment rollout..."

                    kubectl rollout status deployment/trend-app \
                      --timeout=180s

                    echo "Checking application pods..."

                    kubectl get pods -l app=trend-app

                    echo "Checking application service..."

                    kubectl get svc trend-app-service
                '''
            }
        }
    }

    post {
        always {
            sh '''
                docker rm -f trend-ci-test 2>/dev/null || true
            '''
        }

        success {
            echo 'Trend application pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}
