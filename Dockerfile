FROM nginx:stable-alpine3.17-slim

RUN rm -fr /usr/share/nginx/html/*

RUN apk --no-cache add bash curl 

COPY ./web /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

EXPOSE 80 	


