/* import shared library */

@Library('shared-library')_

pipeline {
    environment {
      IMAGE_NAME = 'xxxxx-xxxxx' // your image name
      DOCKER_HUB_ID = 'xxxxx-xxxxxxx'  // your id on docker hub
      IMAGE_TAG_PRODUCTION = 'latest'
      CONTAINER_NAME = 'webapp-container'
      PORT_EXTERNE = 80
      PORT_INTERNE = 80
      IP_DOCKER_JOKER = '172.17.0.1'
      PATH_COHERENCE = '/usr/share/nginx/html/index.html'
      REVIEW_APP_ENDPOINT = 'review.example.com' 
      STAGING_APP_ENDPOINT = 'staging.example.com'
      PRODUCTION_APP_ENDPOINT = 'production.example.com'
      REVIEW_USER = 'jenkins-review'
      STAGING_USER = 'jenkins-staging'
      PRODUCTION_USER = 'jenkins-production'
      MAIN_BRANCH = 'main'
      STAGING_BRANCH = 'fx_1'
    }
    agent any 
    stages{
        stage('BUILD_IMAGE') {
          agent any 
          steps {
            script {
              sh '''
              COMMIT=from-commit-${GIT_COMMIT:0:7}
              docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${COMMIT} -f web/Dockerfile .
              docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG_PRODUCTION} -f web/Dockerfile .
              '''
            }
          }
        }
        stage('START_CONTAINER') {
          agent any 
          steps {
            script {
              sh ''' 
                COMMIT=from-commit-${GIT_COMMIT:0:7}
                docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${COMMIT}
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
                COMMIT=from-commit-${GIT_COMMIT:0:7}
                curl http://${NODE_NAME} | grep -q "JENKINS NOTYLUS GROUP"
                expected_content=$(docker run --rm ${DOCKER_HUB_ID}/${IMAGE_NAME}:${COMMIT} cat ${PATH_COHERENCE})
                actual_content=$(docker run --rm ${DOCKER_HUB_ID}/${IMAGE_NAME}:${COMMIT} curl -s http://${IP_DOCKER_JOKER}:${PORT_EXTERNE})
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
                COMMIT=from-commit-${GIT_COMMIT:0:7}
                docker run --rm ${DOCKER_HUB_ID}/${IMAGE_NAME}:${COMMIT} curl -s -o /dev/null -w "%{http_code}" https://example.com
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
                COMMIT=from-commit-${GIT_COMMIT:0:7}
                docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" 
                docker push ${DOCKER_HUB_ID}/${IMAGE_NAME}:${COMMIT}
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
              sh '''
                COMMIT=from-commit-${GIT_COMMIT:0:7}
                ssh -o StrictHostKeyChecking=no $REVIEW_USER@$REVIEW_APP_ENDPOINT
                ssh $REVIEW_USER@$REVIEW_APP_ENDPOINT "docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${COMMIT}"
                ssh $REVIEW_USER@$REVIEW_APP_ENDPOINT "docker rm -f ${CONTAINER_NAME}"
              '''
            }
          }
        }
        stage('DEPLOY_STAGING') {
          when{
              expression { GIT_BRANCH == 'origin/fx_1' }
          }
          agent any 
          steps {
            sshagent(credentials: ['jenkins-admin-key']) {
              sh '''
                COMMIT=from-commit-${GIT_COMMIT:0:7}
                ssh -o StrictHostKeyChecking=no $STAGING_USER@$STAGING_APP_ENDPOINT
                ssh $STAGING_USER@$STAGING_APP_ENDPOINT "docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${COMMIT}"
                ssh $STAGING_USER@$STAGING_APP_ENDPOINT "docker rm -f ${CONTAINER_NAME}"
              '''
            }
          }
        }   
        stage('DEPLOY_PRODUCTION') {
          when {
              expression { GIT_BRANCH == 'origin/main' }
          }
          agent any 
          steps {
            sshagent(credentials: ['jenkins-admin-key']) {
              sh '''
                ssh -o StrictHostKeyChecking=no $PRODUCTION_USER@$PRODUCTION_APP_ENDPOINT
                ssh $PRODUCTION_USER@$PRODUCTION_APP_ENDPOINT "docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG_PRODUCTION}"
                ssh $PRODUCTION_USER@$PRODUCTION_APP_ENDPOINT "docker rm -f ${CONTAINER_NAME}"
              '''
            }
          }
        }   
    }
  post {
      always{
        script {
          slackNotifier currentBuild.result 
        }
      }  
  }       
}

