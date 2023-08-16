// Pipeline jenkins

pipeline {
    environment {
      IMAGE_NAME = 'jenkins'
      DOCKER_HUB_ID = 'erickmpene'
      IMAGE_TAG = 'latest' 
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
    //
    // parameters {
      // booleanParam(name: 'skip_test', defaultValue: false, description: 'Set to true to skip the test stage')}
    agent none   
    stages{
        stage('BUILD_IMAGE') {
          agent { 
            docker { 
              image 'docker:dind' 
            }
          }
          steps {
              sh 'docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} -f web/Dockerfile .'
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
          when { expression { params.skip_test != true } } 
          steps {
            script {
              sh ''' 
                 docker stop ${CONTAINER_NAME}
                 docker rm ${CONTAINER_NAME}
              '''
            }
          }
        }

     
    }
}       

//
//
//
