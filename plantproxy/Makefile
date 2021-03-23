build:
	DOCKER_BUILDKIT=1 docker build --progress plain --ssh default=${SSH_AUTH_SOCK} -t eu.gcr.io/cwahackathon/plantproxy:latest -f ./Dockerfile .

push: build
	docker push eu.gcr.io/cwahackathon/plantproxy:latest

run_plantuml_server:
	docker run -p 8080:8080 plantuml/plantuml-server:jetty-v1.2021.1

run_docker_basic:
	docker run -ti  --net=bridge -p8081:8081 -ePLANTUML_SERVER=host.docker.internal plantproxy:latest start_iex

apply_to_cluster: 
	tk apply .ci/environments/default

install_cert_manager: 
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.yaml

install_nginx_ingres_controller:

helm_install_nginx:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingres-nginx --create-namespace


