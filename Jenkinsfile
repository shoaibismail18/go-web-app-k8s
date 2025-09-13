pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    stages {

        // Checkout the repository
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // Build the Go application
        stage('Build') {
            steps {
                sh """
                    echo "Building the project"
                    go version
                    go build -o myapp
                """
            }
        }

        // Run tests
        stage('Test') {
            steps {
                sh """
                    echo "Running tests"
                    go test ./...
                """
            }
        }

        // Run code quality / linting
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

        // Docker build and push
        stage('Docker Build and Push') {
            when { branch 'main' }
            steps {
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKERHUB_TOKEN')]) {
                    script {
                        def imageTag = env.BUILD_NUMBER
                        sh """
                            export IMAGE_TAG=${imageTag}
                            echo 'Docker build and push started'
                            echo "\${DOCKERHUB_TOKEN}" | docker login -u "shoaibismail18" --password-stdin
                            docker build -t shoaibismail18/go-web-app:\${IMAGE_TAG} .
                            docker push shoaibismail18/go-web-app:\${IMAGE_TAG}
                            echo 'Docker build and push completed'
                        """
                        env.IMAGE_TAG = imageTag
                        echo "IMAGE_TAG is set to ${env.IMAGE_TAG}"
                    }
                }
            }
        }

        // Update Helm chart and Kubernetes manifests
        stage('Update Helm Chart and K8s Manifests') {
            when { branch 'main' }
            steps {
                withCredentials([string(credentialsId: 'GitHub_credentials', variable: 'GITHUB_TOKEN')]) {
                    sh """
                        git config --global user.email "shoaibismail18@gmail.com"
                        git config --global user.name "shoaibismail18"

                        # Update Helm chart
                        sed -i "s|tag: .*|tag: \\"${IMAGE_TAG}\\"|" helm/go-web-app-chart/values.yaml

                        # Update Kubernetes manifests
                        for file in K8s/Manifests/*.yaml; do
                            sed -i "s|image: shoaibismail18/go-web-app:.*|image: shoaibismail18/go-web-app:${IMAGE_TAG}|" "\$file"
                        done

                        git add helm/go-web-app-chart/values.yaml K8s/Manifests/*.yaml
                        git commit -m "Update image tag to ${IMAGE_TAG}" || echo "No changes to commit"
                        git push https://x-access-token:${GITHUB_TOKEN}@github.com/shoaibismail18/go-web-app-k8s.git HEAD:main
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully."
        }
        failure {
            echo "Pipeline failed."
        }
        always {
            cleanWs()
        }
    }
}
