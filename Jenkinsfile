pipeline {
    agent any
    
    environment {
        // define image environment variables
        IMAGE_NAME = "buildapache"
        IMAGE_TAG = "${GIT_COMMIT_HASH}"
        // define docker registry environment variables
        DOCKERFILE_PATH = "Dockerfile" // Update with the path to your Dockerfile
        DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME')
        DOCKERHUB_PASSWORD = credentials('DOCKERHUB_PASSWORD')
        DOCKERHUB_URI = "docker://${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
        // define ecr registry environment variables
        ECR_REPO_NAME = "${IMAGE_NAME}"
        ECR_REGISTRY_URI = "${AWS_ACCOUNT_NO}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        GIT_COMMIT_HASH = "${sh(returnStdout: true, script: 'git rev-parse --short HEAD')}"
        // define aws environment variables
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-gov-west-1'
        AWS_ACCOUNT_NO = credentials('AWS_ACCOUNT_NO')
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
                    // Build the image using Buildah. Ensure buildah is installed on agent.
                    sh 'buildah bud -t ${IMAGE_NAME}:${IMAGE_TAG} -f ${DOCKERFILE_PATH} .'

                    // List the image to verify that the build was successful.
                    sh 'buildah images ${IMAGE_NAME}'
                }
            }
        }

        stage('Push To Dockerhub') {
            steps {
                script {
                    // login, push, and logout of dockerhub
                    sh "buildah login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD} docker.io"
                    sh "buildah push ${IMAGE_NAME} ${DOCKERHUB_URI}:${IMAGE_TAG}"
                    sh "buildah logout docker.io"
                }
            }
        }

        stage('Push To ECR') {
            // https://buildah.io/blogs/2018/01/26/using-image-registries-with-buildah.html
            steps {
                script {
                    // configure aws cli
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region $AWS_DEFAULT_REGION
                    '''
                }
                script {
                    // login and push to ecr
                    sh '''
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | buildah login --username AWS --password-stdin ${AWS_ACCOUNT_NO}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
                        buildah push ${IMAGE_NAME} ${ECR_REGISTRY_URI}/${ECR_REPO_NAME}:${IMAGE_TAG}
                    '''
                }   
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    sh '''
                        buildah rmi --all
                    '''
                }
            }
        }       
    }
}

