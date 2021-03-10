start-minikube:
	minikube start --feature-gates=TTLAfterFinished=true

deploy:
	kubectl apply -f manifests/hello-namespace.yaml
	kubectl apply -f manifests/hello-deployment.yaml
	kubectl apply -f manifests/hello-service.yaml

build-test:
	eval $$(minikube docker-env) && docker build -f tests/Dockerfile -t kube-test:0.1 tests/

test:
	kubectl config set-context --current --namespace=hello-ns
	kubectl create -f tests/k8s
	# we need to wait while the job will be completed
	# then we can get full log from the completed job
	bash ./wait_for_job.sh
	mkdir -p logs
	# -l job-name will search all pods created by jobs
	kubectl logs $$(kubectl get pods -l job-name --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}') > logs/$$(date +%s)-job.log
	# kubectl delete -f tests/k8s
