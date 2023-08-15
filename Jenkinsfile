pipeline {
    environment {
      IMAGE_NAME = 
      IMAGE_TAG =
      CONTAINER_NAME =
      PORT_EXTERNE =
      PORT_INTERNE = 
    }
}       



#! /usr/bin/bash
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
docker run -d --name ${CONTAINER_NAME} -p ${PORT_EXTERNE}:${PORT_INTERNE}
