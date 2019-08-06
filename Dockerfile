# => Build container
FROM node:alpine as builder
WORKDIR /app
COPY package.json .
COPY yarn.lock .
RUN yarn
COPY . .
RUN yarn build

FROM dmetzler/go-deploy
ENV SRC_DIR=/src
COPY --from=builder /app/build $SRC_DIR
