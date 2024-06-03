# REST API

[Grape](https://github.com/ruby-grape/grape/tree/v2.0.0?tab=readme-ov-file#versioning)


## Puma

```
bundle exec puma
```

```
curl http://localhost:3000/v1/hello_world/
```

[systemd](https://github.com/puma/puma/blob/master/docs/systemd.md)


# DB Access

## Active Record

```shell
SERVICE_APP_ENV=development rake --tasks
```

```shell
SERVICE_APP_ENV=development rake db:create_migration create_user
```

## Sequel

branch: [feature/sequel-db-access-toolkit](https://github.com/AlexeyAlexey/example_service/tree/feature/sequel-db-access-toolkit)


# Jobs

```shell
SERVICE_APP_ENV=development SIDEKIQ_REDIS_URL='redis://127.0.0.1:6379/0' bundle exec sidekiq -r ./config/environment.rb
```


# Docker

```
docker build -f restapi.Dockerfile . -t restapi-service -t restapi-service:1.0

docker build -f jobs.Dockerfile . -t jobs-service -t jobs-service:1.0

```

If you want to set environment variables when you run a container

```
docker run -e SERVICE_APP_ENV='development' -e SIDEKIQ_REDIS_URL='redis://redis:6379/0' jobs-service

```


```
docker-compose up

docker-compose run --rm -e SERVICE_APP_ENV=test restapi rspec

docker-compose exec -e SERVICE_APP_ENV=test restapi rspec
```

Creating DB

```
docker-compose exec restapi rake db:create
```

```
docker-compose exec restapi rake db:migrate
```

List of tasks

```
docker-compose exec restapi rake -T
```

## Production Environment

```
docker build -f restapi.Dockerfile.prod -t <username>/<image name>:prod .
docker build -f jobs.Dockerfile.prod -t <username>/<image name>:prod .
```


# Kubernetes


## Installing

https://minikube.sigs.k8s.io/docs/start/


Drivers

https://minikube.sigs.k8s.io/docs/drivers/


The docker minikube driver was used

```shell
minikube start --driver docker
```

## Configuration

Deployment ([Doc](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/))

Service ([Doc](https://kubernetes.io/docs/tutorials/services/connect-applications-service/))


**Deployment** is for stateless Apps

**Statefulset** is for statefull Apps or Databases ([Doc](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/))

DB are often hosted outside of Kubernetes cluster


### DB

Deployment was used (```replicas: 1```) to simplify an example


```
postgres-config.yaml
```

#### Secrets

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code. ([Doc](https://kubernetes.io/docs/concepts/configuration/secret/))

Don't use the following simple example in a production env. You should read documentation to know more about it.

```
postgres-secret.yaml
```

#### Deployment-Service

```
postgres.yaml 
```

### App

#### Deployment-Service

restapi.yaml


Exposing the Service ([Doc](https://kubernetes.io/docs/tutorials/services/connect-applications-service/#exposing-the-service))

```yaml
spec:
  type: NodePort
```

Exposing the Service on each Node's IP at static port
```yaml
nodePort: 30000
```

## To use an image without uploading it

To use an image without uploading it, you can follow these steps.
It is important that you be in the same shell since you are setting environment variables!

1. Setting the environment variables with

```shell
  example_service$ eval $(minikube docker-env)
```

2. Building the image (eg docker build -t my-image .)

```shell
example_service$ docker build --no-cache -f restapi.Dockerfile . -t restapi-service -t restapi-service:2.0
```

3. Setting the image in the pod spec like the build tag

```
restapi.yaml
```

```yaml
spec:
  containers:
  - name: restapi
    image: restapi-service:2.0
    imagePullPolicy: Never
```

4. Setting the **imagePullPolicy** to **Never**, otherwise, Kubernetes will try to download the image.

```
restapi.yaml
```

```yaml
spec:
  containers:
  - name: restapi
    image: restapi-service:2.0
    imagePullPolicy: Never
```

[imagePullPolicy Never](https://kubernetes.io/docs/concepts/containers/images/#updating-images)




## Deploying

```shell
example_service$ kubectl apply -f postgres-config.yaml
```

```shell
example_service$ kubectl apply -f postgres-secret.yaml
```

```shell
example_service$ kubectl apply -f postgres.yaml
deployment.apps/postgres-deployment created
service/postgres-service created
```

```shell
$ kubectl apply -f restapi.yaml
deployment.apps/restapi-deployment created
service/restapi-service created
```


You can use the following commands to get more details

```shell
$ kubectl get all

$ kubectl get configmap

$ kubectl get secret
```

```shell
$ kubectl get pod
NAME                                   READY   STATUS    RESTARTS   AGE
postgres-deployment-6dd86bd65f-v9wbb   1/1     Running   0          18h
restapi-deployment-68b659d5fd-qjkp6    1/1     Running   0          34m
```

```shell
$ kubectl describe service restapi-service
```

```shell
$ kubectl describe pod restapi-deployment-68b659d5fd-qjkp6
```

## View logs of container

```shell
$ kubectl get pod
NAME                                   READY   STATUS    RESTARTS   AGE
postgres-deployment-6dd86bd65f-v9wbb   1/1     Running   0          18h
restapi-deployment-68b659d5fd-qjkp6    1/1     Running   0          34m
```

```shell
$ kubectl logs restapi-deployment-7468df8fcc-h9rvb -f
```

## Getting IP adress to access the restapi app

```shell
$ kubectl get svc
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP          40h
postgres-service   ClusterIP   10.97.184.253    <none>        5432/TCP         19h
restapi-service    NodePort    10.110.203.236   <none>        3000:30000/TCP   19h
```

```shell
$ kubectl get node -o wide
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
minikube   Ready    control-plane   21h   v1.30.0   192.168.49.2   <none>        Ubuntu 22.04.4 LTS   5.15.0-102-generic   docker://26.0.1

```

## Testing

```shell
curl http://192.168.49.2:30000/v1/hello_world/
{"message":"Hello World"}
```

```shell
curl http://192.168.49.2:30000/v1/hello_world/db_version
{"message":"PostgreSQL 16.3 (Debian 16.3-1.pgdg120+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit"}
```