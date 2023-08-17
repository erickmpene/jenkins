// Pipeline jenkins

pipeline {
    environment {
      IMAGE_NAME = 'jenkins'
      DOCKER_HUB_ID = 'erickmpene'
      IMAGE_TAG = "${env.GIT_BRANCH}"
      IMAGE_TAG_PRODUCTION = 'latest'
      CONTAINER_NAME = 'webapp-container'
      PORT_EXTERNE = 80
      PORT_INTERNE = 80
      IP_DOCKER_JOKER = '172.17.0.1'
      PATH_COHERENCE = '/usr/share/nginx/html/index.html'
      REVIEW_APP_ENDPOINT = 'review.notylus.local' 
      STAGING_APP_ENDPOINT = 'staging.notylus.local'
      PRODUCTION_APP_ENDPOINT = 'production.notylus.local'
      REVIEW_USER = 'jenkins-review'
      STAGING_USER = 'jenkins-staging'
      PRODUCTION_USER = 'jenkins-production'
    }
    agent none   
    stages{
        stage('debug') {
          agent any 
          steps{
              script {
                sh 'printenv'
                // echo "BRANCH_NAME is ${env.GIT_BRANCH}"
                // echo "BRANCH_NAME is ${env.BUILD_NUMBER}"
                // echo "BRANCH_NAME is ${env.BUILD_ID}"
                // echo "BRANCH_NAME is ${env.BUILD_DISPLAY_NAME}"
                // echo "BRANCH_NAME is ${env.JOB_NAME}"
                // echo "BRANCH_NAME is ${env.JOB_BASE_NAME}"
                // echo "BRANCH_NAME is ${env.BUILD_TAG}"
                // echo "BRANCH_NAME is ${env.EXECUTOR_NUMBER}"
                // echo "BRANCH_NAME is ${env.NODE_NAME}"
                // echo "BRANCH_NAME is ${env.NODE_LABELS}"
                // echo "BRANCH_NAME is ${env.WORKSPACE}"

                echo "You can also use \${BUILD_NUMBER} -> ${BUILD_NUMBER}"
              }
          }
        }
        stage('BUILD_IMAGE') {
          agent any
          steps {
            script {
              sh 'docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} -f web/Dockerfile .'
              sh 'docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG_PRODUCTION} -f web/Dockerfile .'
            }
          }
        }
        stage('START_CONTAINER') {
          agent any 
          steps {
            script {
              sh ''' 
                 docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}
                 sleep 5
              '''
            }
          }
        }
        stage('TEST COHERENCE') {
          agent any
          steps {
            script {
              sh ''' 
                 curl http://${NODE_NAME} | grep -q "JENKINS NOTYLUS GROUP"
                 expected_content=$(docker run --rm ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} cat ${PATH_COHERENCE})
                 actual_content=$(docker run --rm ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} curl -s http://${IP_DOCKER_JOKER}:${PORT_EXTERNE})
                 if [ "$actual_content" != "$expected_content" ]; then echo "Contenu incorrect"; exit 1; fi
              '''
            }
          }
        }
        stage('TEST DISPONIBILITE') {
          agent any  
          steps {
            script {
              sh ''' 
                 docker run --rm ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} curl -s -o /dev/null -w "%{http_code}" https://example.com
              '''
            }
          }
        }
        stage('TEST LIEN') {
          agent any  
          steps {
            script {
              sh ''' 
                 docker run --rm dcycle/broken-link-checker:3 http://${IP_DOCKER_JOKER}:${PORT_EXTERNE}
              '''
            }
          }
        }
        stage('TEST PERFORMANCE') {
          agent any  
          steps {
            script {
              sh ''' 
                 docker run --rm jordi/ab -k -c 100 -n 100000  http://${IP_DOCKER_JOKER}:${PORT_EXTERNE}/
              '''
            }
          }
        }
        stage('DELETE_CONTAINER') {
          agent any  
          steps {
            script {
              sh ''' 
                 docker stop ${CONTAINER_NAME}
                 docker rm ${CONTAINER_NAME}
              '''
            }
          }
        }
        stage('RELEASE_IMAGE') {
          agent any  
          steps {
            script {
              sh ''' 
                  docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" 
                  docker push ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}
                  docker push ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG_PRODUCTION}

              '''
            }
          }
        }
        stage('DEPLOY_REVIEW') {
          when{
              changeRequest()
          }
          agent any 
          steps {
            sshagent(credentials: ['jenkins-admin-key']) {
              sh 'ssh -o StrictHostKeyChecking=no $REVIEW_USER@$REVIEW_APP_ENDPOINT'
              sh 'ssh $REVIEW_USER@$REVIEW_APP_ENDPOINT "docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}"'
              sh 'ssh $REVIEW_USER@$REVIEW_APP_ENDPOINT "docker rm -f ${CONTAINER_NAME}"'
            }
          }
        }
        stage('DEPLOY_STAGING') {
          when{
              branch "fx_1"
          }
          agent any 
          steps {
            sshagent(credentials: ['jenkins-admin-key']) {
              sh 'ssh -o StrictHostKeyChecking=no $STAGING_USER@$STAGING_APP_ENDPOINT'
              sh 'ssh $STAGING_USER@$STAGING_APP_ENDPOINT "docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}"'
              sh 'ssh $STAGING_USER@$STAGING_APP_ENDPOINT "docker rm -f ${CONTAINER_NAME}"'
            }
          }
        }   
        stage('DEPLOY_PRODUCTION') {
          when{
              branch "main"
          }
          agent any 
          steps {
            sshagent(credentials: ['jenkins-admin-key']) {
              sh 'ssh -o StrictHostKeyChecking=no $PRODUCTION_USER@$PRODUCTION_APP_ENDPOINT'
              sh 'ssh $PRODUCTION_USER@$PRODUCTION_APP_ENDPOINT "docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG_PRODUCTION}"'
              sh 'ssh $PRODUCTION_USER@$PRODUCTION_APP_ENDPOINT "docker rm -f ${CONTAINER_NAME}"'
            }
          }
        }   
    }
}       

//



