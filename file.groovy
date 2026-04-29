pipeline{
    agent any

    environment{
        APP_NAME = 'nodejs-simple-api-with-db'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        IMAGE_REPO = 'pouriyamp/nodejs-simple-api-with-db'
        IMAGE_URI = "${IMAGE_REPO}:${IMAGE_TAG}"
        IMAGE_LATEST = "${IMAGE_REPO}:latest"
        SONARSERVER = 'sonarqube-server'
        SONARSCANNER = 'sonar-scanner'
    }

    stages{    

        stage('fix and install Dep'){
            steps{
                sh 'npm ci'
            }
        }

        stage('Run tests'){
            steps{
                sh 'npm run test:cov'
            }
        }
        stage('build'){
            steps{
                sh 'npm run build'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv("${SONARSERVER}") {
                    script{
                        def scannerHome = tool 'sonar-scanner'
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=nodejs-simple-api-with-db \
                            -Dsonar.projectName=nodejs-simple-api-with-db \
                            -Dsonar.sources=src \
                            -Dsonar.tests=tests \
                            -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                            -Dsonar.sourceEncoding=UTF-8
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
                }
            }
        }
    

        stage('Trivy Filesystem Scan') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL --scanners vuln,secret .'
            }
        }

        stage('Build docker Image'){
            steps{
                sh 'docker build --no-cache -t $IMAGE_URI .'
            }
        }

        stage('Trivy Image Scan') {
        steps {
            sh "trivy image --scanners vuln --ignore-unfixed --severity CRITICAL --exit-code 1 ${IMAGE_URI}"
            }
        }

        stage('push image'){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'docker',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]){
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push "$IMAGE_URI
                      docker logout 
                    '''
                }
                
            }
        }
        
        stage('Deploy to dev'){
            steps{
                sh '''
                  ansible-playbook -i Infra/ansible/inventory.yml Infra/ansible/deploy_inside_jenkins.yml \
                  --extra-vars "image_uri=$IMAGE_URI" \
                  --extra-vars "database_url=$DATABASE_URL" \
                  --extra-vars "app_port=3000"
                '''
            }
        }
    }
}