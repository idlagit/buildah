pipeline {
    agent any
    
    environment {
        // define image environment variables
        IMAGE_NAME = "myapache"
        IMAGE_TAG = "${GIT_COMMIT_HASH}"
        DOCKERFILE_PATH = "Dockerfile" // Update with the path to your Dockerfile
        DOCKERHUB_REPO_NAME = "buildah"
        GIT_COMMIT_HASH = "${sh(returnStdout: true, script: 'git rev-parse --short HEAD')}"
    }

    stages {
        stage('Checkout') {
            steps {
                // checkout code from github
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/idlagit/buildah']])
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Install Buildah if not already installed (Linux specific)
                    // sh 'sudo apt-get install -y buildah' // Use the appropriate package manager for your system

                    // Build the image using Buildah.
                    sh 'buildah bud -t ${IMAGE_NAME}:${IMAGE_TAG} -f ${DOCKERFILE_PATH} .'

                    // List the images to verify that the build was successful.
                    sh 'buildah images'
                }
            }
        }

        stage('Push Image to dockerhub') {
            // https://buildah.io/blogs/2018/01/26/using-image-registries-with-buildah.html
            // when {
            //     // Add conditions to determine when to push the image to a container registry
            //     // For example, after successful tests
            // }
            steps {
                script {
                    // login to dockerhub
                    withCredentials([usernamePassword(
                        credentialsId: 'DOCKERHUB_CREDENTIALS', 
                        passwordVariable: 'DOCKERHUB_PASSWORD',
                        usernameVariable: 'DOCKERHUB_USERNAME')]) 
                    {
                        sh "buildah login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD} docker.io"
                        // push to dockerhub registry
                        // Example: docker push my-registry/${IMAGE_NAME} 
                        sh "buildah push ${IMAGE_NAME} docker://${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "buildah logout docker.io"
                    }             
                }
            }
        }
    }
}
