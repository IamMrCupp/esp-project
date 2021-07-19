# dockerfile for making the ESP site container

# build using a big os container
FROM node AS base
WORKDIR /tmp/website
COPY ./package*.json .
RUN npm install

# make the container we will use for test/dev/etc
FROM base AS src
COPY ./app/ /tmp/website/

# testing
FROM nginx:alpine AS test
COPY --from=src /tmp/website /usr/share/nginx/html

# package the application in a small container using alpine
FROM nginx:alpine AS prod
COPY --from=src  /tmp/website /usr/share/nginx/html