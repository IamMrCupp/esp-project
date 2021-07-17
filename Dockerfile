# dockerfile for making the ESP site container

FROM node AS builder

WORKDIR /tmp/website
COPY ./package*.json .
RUN npm install
COPY ./app/ /tmp/website/


FROM nginx:alpine
COPY --from=builder  /tmp/website /usr/share/nginx/html