
# Example: run tests in the k8s cluster

## Prerequesites
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Install [minikube](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)


## Run application in minio cluster

Start minikube with TTLAfterFinished flag:
```
minikube start --feature-gates=TTLAfterFinished=true
```

Switch to minio docker deamon:
```bash
eval $$(minikube docker-env)
```

Apply manifests for namespace, application and service:
```
kubectl apply -f manifests/
```

<!-- Expose service port to access the application locally:
``` bash
kubectl port-forward service/hello 7080:8080 --namespace hello-ns
``` -->

## Dockerize tests

Build docker image:
```bash
docker build -t kube-test:0.1 .
```

<!-- Run tests locally (set up net=host to have access to localhost net):
```bash
docker run --net=host --rm --name kube-test kube-test:0.1 test_smoke.py
``` -->

## Run tests in k8s
Tests run in the kubernetes cluster so they can access our service using DNS service name (`http://hello.hello-ns.svc.cluster.local:8081`).

Apply manifests for the application, service and namespace. If you see the error you should try to apply it one more time. The issue is that namespace should be created before other resources will be created.

Set context:
```
kubectl config set-context --current --namespace=hello-ns
```

Build docker image in the docker deamon from Minikube:
```bash
eval $(minikube docker-env)
cd tests
docker build -t kube-test:0.1 .
```

Run tests as kubernetes job:
```bash
kubectl create -f tests/k8s/
```

Get logs from job:
```bash
kubectl logs $(kubectl get pods -l job-name --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}') 
```

You should see:
```
Status code: 200
```

Check that job is completed successfully (status should be `Complete`).
For failed tests it will have `Failed` status.
```
kubectl get jobs --sort-by=.metadata.creationTimestamp -o jsonpath='{..items[-1:]..conditions[0].type}'
```

Change the host port to the wrong value: `8082` inside the test_smoke.py file, build the test again and see that job has `Failed` status now.
```bash
make build-test 
make test
kubectl get jobs --sort-by=.metadata.creationTimestamp -o jsonpath='{..items[-1:]..conditions[0].type}'
```

## Clean mechanism for jobs [docs](https://kubernetes.io/docs/concepts/workloads/controllers/job/#ttl-mechanism-for-finished-jobs)
Job manifest has ttlSecondsAfterFinished setting which tell the k8s to delete job after the specified time (auto clean mechanism).

## Miinikube dashboard
You can see the jobs and their statuses using minikube dashboard. Start minikube dashboard:
```bash
minikube dashboard
```

It will open the minikube dashboard in your current browser.
Choose the hello-ns namespace there and open the jobs tab to see running jobs.


# Run tests using makefile
You can set up everything also using Makefile
```
make start-minikube
make deploy
make build-test
make test
```

# TODO: Save test reports to minio bucket
<!-- Run minio
```
docker run --rm -p 9000:9000 \
    -e "MINIO_ROOT_USER=test-user" \
    -e "MINIO_ROOT_PASSWORD=test-password" \
    minio/minio server /data
```

Set up minio client:
```
docker pull minio/mc
docker run -it --entrypoint=/bin/sh minio/mc
mc config host add minio http://127.0.0.1:9000 test-user test-password
```

Create bucket with minio client. Use mc inside docker container:
```
mc mb minio/reports
``` -->
