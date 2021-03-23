build:
	DOCKER_BUILDKIT=1 docker build --progress plain --ssh default=${SSH_AUTH_SOCK} -t plantproxy:latest -f ./Dockerfile .

run_plantuml_server:
	docker run -p 8080:8080 plantuml/plantuml-server:jetty-v1.2021.1

run_docker_basic:
	docker run -ti  --net=bridge -p8081:8081 -ePLANTUML_SERVER=host.docker.internal plantproxy:latest start_iex
