pipeline {
    agent any
    
    environment {
        IMAGE_NAME = "my-web-app-image:latest"
        DOCKERFILE_PATH = "Dockerfile" // Update with the path to your Dockerfile
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout your source code from your version control system (e.g., Git).
                // Replace with the appropriate SCM tool and repository URL.
                // checkout scm
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/idlagit/buildah']])
                // git 'https://github.com/idlagit/buildah.git'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Install Buildah if not already installed (Linux specific)
                    sh 'sudo yum install -y buildah' // Use the appropriate package manager for your system

                    // Build the image using Buildah.
                    sh "buildah bud -t ${IMAGE_NAME} -f ${DOCKERFILE_PATH} ."

                    // List the images to verify that the build was successful.
                    sh 'buildah images'
                }
            }
        }
    }
}
