// Pipeline jenkins

pipeline {
    environment {
      IMAGE_NAME = 'jenkins'
      DOCKER_HUB_ID = 'erickmpene'
      IMAGE_TAG = 'latest' 
      CONTAINER_NAME = 'webapp-container'
      PORT_EXTERNE = 80
      PORT_INTERNE = 80
    }
    agent none
    stages{
        stage('CONSTRUCTION_IMAGE') {
          agent any
          steps {
            script {
              sh 'docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} -f web/Dockerfile .'
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
        stage('TEST_ACCEPTATION') {
          agent any
          steps {
            script {
              sh ''' 
                 curl http://${NODE_NAME} | grep -q "JENKINS NOTYLUS GROUP"
              '''
            }
          }
          stage('TEST DISPONIBILITE') {
              steps {
                  echo "This is TEST DISPONIBILITE"
              }
          }
        }
        stage('TEST COHERENCE') {
          agent any  
          steps {
            script {
              sh ''' 
                 echo "This is TEST COHERENCE"

              '''
            }
          }
        }
        stage('Destroy Container') {
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
    }
}       
