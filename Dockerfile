# dockerfile for making the ESP site container

# build using a big os container
FROM node AS dev

WORKDIR /tmp/website
COPY ./package*.json .
RUN npm install
COPY ./app/ /tmp/website/

# package the application in a small container using alpine
FROM nginx:alpine AS prod
COPY --from=dev  /tmp/website /usr/share/nginx/html