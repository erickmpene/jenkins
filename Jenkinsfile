pipeline {
    environment {
      IMAGE_NAME = jenkins
      DOCKER_HUB_ID = erickmpene
      IMAGE_TAG = latest 
      CONTAINER_NAME = webapp-container
      PORT_EXTERNE = 80
      PORT_INTERNE = 80
    }
    agent none 
    stages{
        stage('Build image') {
          agent any
          steps {
            script {
              sh 'docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} -f web/Dockerfile .'
            }
          }
        }
        stage('Run container based on builded image') {
          agent any
          steps {
            script {
              sh ''' 
                 docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                 sleep 5
              '''
            }
          }
        }
        stage('Test image') {
          agent any
          steps {
            script {
              sh ''' 
                 curl http://${NODE_NAME} | grep -q "JENKINS NOTYLUS GROUP"
              '''
            }
          }
        }
        stage('Clean Container') {
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
