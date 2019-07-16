The idea behind this project is to provide a way to package a statically build application as a Docker image, and the deploy it on various scenarios:

 * docker-compose
 * k8s
 * s3

# Building the image

```console
docker build -t dmetzler/static-html .
```

# Running the image

The idea is to serve the static files with an NGinx server that is run as a sidecar. The image has a command that allows copy our static files in a destination volume.


## Deploy with Docker Compose

```yaml
version: '3'
services:

  html:
    image: dmetzler/static-html
    command: vol /html_dir
    environment:
      API_URL: https://jsonplaceholder.typicode.com/users
    volumes:
    - html:/html_dir/
  nginx:
    image: nginx
    ports:
      - "8080:80"
    volumes:
    - html:/usr/share/nginx/html/:ro

volumes:
  html:
```

## Deploy with Openshift / Kubernetes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  initContainers:
  - name: html
    image: dmetzler/static-html
    imagePullPolicy: Always
    command:
    - "/entrypoint.sh"
    - "vol"
    - "/html_dir"
    env:
    - name: API_URL
      value: https://jsonplaceholder.typicode.com/users
    volumeMounts:
    - name: htmldir
      mountPath: /html_dir

  containers:
  - name: nginx
    image: twalter/openshift-nginx:stable
    ports:
    - containerPort: 8081
    volumeMounts:
    - name: htmldir
      mountPath: /usr/share/nginx/html/
      readOnly: true
  volumes:
    - name: htmldir
      emptyDir: {}
```

## Deploy to s3

```console
# docker run --rm \
     -e API_URL=https://jsonplaceholder.typicode.com/users \
     -e AWS_ACCESS_KEY_ID \
     -e AWS_SECRET_ACCESS_KEY \
     -e AWS_DEFAULT_REGION \
     -e AWS_SESSION_TOKEN \
     -it dmetzler/static-html s3 s3://mysamplestaticapp.com

# open http://mysamplestaticapp.com.s3-website-us-east-1.amazonaws.com
```

# Environment variables

All environment variables references in the `.env` file are evaluated at runtime and rendered in a `env-config.js` file that is included in `index.html`.

The environment variable values are then available under the `window._env_` variable.

```javascript
window._env_ = {
  API_URL: "https://jsonplaceholder.typicode.com/users",
}
```

# Evolutions

## Distroless

The resulting image is based on `amazonlinux` and is quite big, just to have th `aws-cli` utils and being able to run bash.

In order to use a distroless Docker image, we could build a Go based entrypoint that also takes care of the sync to s3.


## Base image

Instead of using a multi-step build, we could provide a base image that embeds everything, so that the result is easier to use for someone who just wants to package some static assets.

# Reference:

 * [How to implement runtime environment variables](https://www.freecodecamp.org/news/how-to-implement-runtime-environment-variables-with-create-react-app-docker-and-nginx-7f9d42a91d70/)