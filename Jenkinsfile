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
    agent none   
    stages{
        stage('DEPLOY_STAGING') {
          agent any 
          steps {
            script {
              sh ''' 
                 sshagent(["jenkins-admin-key"]) {
                  sh 'ssh $STAGING_USER@$STAGING_APP_ENDPOINT "docker run -d --name test -p 80:80 nginx"'
                  # sh 'ssh $STAGING_USER@$STAGING_APP_ENDPOINT "docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE} ${DOCKER_HUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}"'
                 }
                 
                 echo "ceci est un test"
              '''
            }
          }
        }

     
    }
}       

//
//
//

