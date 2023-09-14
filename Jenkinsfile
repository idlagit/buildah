pipeline {
    agent any
    
    environment {
        // define image environment variables
        IMAGE_NAME = "buildahApache"
        IMAGE_TAG = "${GIT_COMMIT_HASH}"
        DOCKERFILE_PATH = "Dockerfile" // Update with the path to your Dockerfile
        DOCKERHUB_REPO_NAME = "${IMAGE_NAME}"
        ECR_REPO_NAME = "${IMAGE_NAME}"
        GIT_COMMIT_HASH = "${sh(returnStdout: true, script: 'git rev-parse --short HEAD')}"
    }

    stages {
        stage('Checkout Code') {
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
                    sh 'buildah images ${IMAGE_NAME}'
                }
            }
        }

        stage('Push To Dockerhub') {
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

        stage('Push To ECR') {
            // https://buildah.io/blogs/2018/01/26/using-image-registries-with-buildah.html
            environment {
                AWS_REGION = "us-gov-west-1"
            }
            steps {
                script {
                    // login and push to ecr
                    withCredentials([string(
                        credentialsId: 'AWS_ACCOUNT_NO', 
                        variable: 'AWS_ACCOUNT_NO')]) 
                    {
                        sh "aws ecr get-login-password --region ${env.AWS_REGION} | buildah login --username AWS --password-stdin ${AWS_ACCOUNT_NO}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                        sh "buildah push ${IMAGE_NAME} ${AWS_ACCOUNT_NO}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    }             
                }
            }
        }        
    }
}
