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
                sh '''#!/bin/bash
                set +x
                set -e

            export AWS_DEFAULT_REGION=ap-south-2

            echo "Assuming dedicated Jenkins deployment role..."

            read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< "$(
                aws sts assume-role \
                  --role-arn arn:aws:iam::829786863239:role/Trend-Jenkins-EKS-Deploy-Role \
                  --role-session-name Jenkins-${BUILD_NUMBER} \
                  --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
                  --output text
            )"

            export AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY
            export AWS_SESSION_TOKEN

            echo "Verifying AWS identity..."
            aws sts get-caller-identity

            export KUBECONFIG=$(mktemp)

            cleanup() {
                rm -f "$KUBECONFIG"
            }
            trap cleanup EXIT

            echo "Connecting to EKS..."
            aws eks update-kubeconfig \
              --name trend-eks \
              --region ap-south-2 \
              --kubeconfig "$KUBECONFIG"

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

            echo "Deployment completed using dedicated Jenkins IAM role."
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
