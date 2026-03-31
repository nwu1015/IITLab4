FROM nginx:alpine

RUN  /usr/share/nginx/html/*

COPY . /usr/share/nginx/html

EXPOSE 80
