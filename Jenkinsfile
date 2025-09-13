pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh """
                    echo "Building the project"
                    go version
                    go build -o myapp 
                """
            }
        }

        stage('Test') {
            steps {
                sh """
                    echo "Running tests"
                    go test ./...
                """
            }
        }

        stage('Code Quality') {
            steps {
                sh """
                    echo "Installing golangci-lint"
                    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
                    export PATH=\$(go env GOPATH)/bin:\$PATH
                    golangci-lint version
                    golangci-lint run --timeout=10m
                """
            }
        }

        stage('Docker build and push') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKERHUB_TOKEN')]) {
                    script {
                        def imageTag = env.BUILD_NUMBER
                        sh """ 
                            echo 'Docker build and push started'
                            echo "\${DOCKERHUB_TOKEN}" | docker login -u "shoaibismail18" --password-stdin
                            docker build -t shoaibismail18/go-web-app:${imageTag} .
                            docker push shoaibismail18/go-web-app:${imageTag}
                            echo 'Docker build and push completed'
                        """
                        env.IMAGE_TAG = imageTag
                        echo "IMAGE_TAG is set to ${env.IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Helm Chart') {
            steps {
                withCredentials([string(credentialsId: 'GitHub_credentials', variable: 'GITHUB_TOKEN')]) {
                    sh """
                        git config --global user.email "shoaibismail18@gmail.com"
                        git config --global user.name "shoaibismail18"
                        echo "Updating manifests files in Helm folder"
                        sed -i "s|tag: .*|tag: \\"${IMAGE_TAG}\\"|" helm/go-web-app-chart/values.yaml
                        git add helm/go-web-app-chart/values.yaml
                        git commit -m "Updating image tag to ${IMAGE_TAG}" || echo "No changes to commit"
                        git push https://x-access-token:${GITHUB_TOKEN}@github.com/shoaibismail18/go-web-app-k8s.git HEAD:main
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully."
        }
        failure {
            echo "❌ Pipeline failed."
        }
        always {
            cleanWs()
        }
    }
}
