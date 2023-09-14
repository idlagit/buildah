pipeline {
    agent any
    
    environment {
        // define environment variables
        IMAGE_NAME = "buildapache"
        IMAGE_TAG = "${GIT_COMMIT_HASH}"

        DOCKERFILE_PATH = "Dockerfile" // Update with the path to your Dockerfile
        DOCKERHUB_REPO_NAME = "${IMAGE_NAME}"

        ECR_REPO_NAME = "${IMAGE_NAME}"
        ECR_REGISTRY_URI = "${AWS_ACCOUNT_NO}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"

        GIT_COMMIT_HASH = "${sh(returnStdout: true, script: 'git rev-parse --short HEAD')}"

        AWS_ACCESS_KEY_ID = withCredentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = withCredentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-gov-west-1'
        AWS_ACCOUNT_NO = withCredentials('AWS_ACCOUNT_NO')
        
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

        stage('Configure awsCLI') {
            steps {
                script {
                    sh "aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID"
                    sh "aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY"
                    sh "aws configure set region $AWS_DEFAULT_REGION"
                }
            }
        }

        stage('Push To ECR') {
            // https://buildah.io/blogs/2018/01/26/using-image-registries-with-buildah.html

            steps {
                script {
                    // login and push to ecr
                    // withCredentials([string(
                    //     credentialsId: 'AWS_ACCOUNT_NO', 
                    //     variable: 'AWS_ACCOUNT_NO')]) 
                    {
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | buildah login --username AWS --password-stdin ${AWS_ACCOUNT_NO}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                        sh "buildah push ${IMAGE_NAME} ${ECR_REGISTRY_URI}/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    }             
                }
            }
        }        
    }

    post {
        always {
            // Clean up AWS CLI configuration
            sh 'aws configure unset aws_access_key_id'
            sh 'aws configure unset aws_secret_access_key'
        }
}

