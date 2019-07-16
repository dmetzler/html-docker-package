# => Build container
FROM node:alpine as builder
WORKDIR /app
COPY package.json .
COPY yarn.lock .
RUN yarn
COPY . .
RUN yarn build

FROM amazonlinux
ENV SRC_DIR=/app
ENV HTML_DIR=/html_dir
RUN yum -y update && yum -y install aws-cli
COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /app/build $SRC_DIR
ENTRYPOINT [ "/entrypoint.sh" ]