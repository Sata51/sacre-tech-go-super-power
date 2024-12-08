PROJECT_NAME := "sacre-tech-go-super-power"
PKG := github.com/Sata51/$(PROJECT_NAME)
GO_FILES := $(shell find . -name '*.go' | grep -v /vendor/ | grep -v _test.go)
GO_FILES_WITH_TEST := $(shell find . -name '*.go' | grep -v /vendor/)

PKG_SERVER := $(PKG)/cmd/sacre-tech-go-super-power
PKG_SERVER_BIN := dist/sacre-tech-go-super-power
PKG_SERVER_BIN_SHRINKED := dist/sacre-tech-go-super-power-shrinked

dependency:
	@echo "Fetching dependencies"
	@go get -u ./...
	@go mod vendor
	@go mod tidy

build:
	@echo "Building server"
	@mkdir -p dist
	@go build -mod=vendor -v -o ${PKG_SERVER_BIN} $(PKG_SERVER)
	@go build -mod=vendor -v -ldflags="-s -w" -o ${PKG_SERVER_BIN_SHRINKED} $(PKG_SERVER)

run: build
	@echo "Running server"
	@./${PKG_SERVER_BIN}


create-task:
	@echo "Creating task"
	@./create-task.sh 100 8080

bench-echo:
	@echo "Benchmarking echo"
	@hey -n 10000 -c 100 http://localhost:8080/echo?name=sacré-tech

bench-tasks:
	@echo "Benchmarking tasks"
	@hey -n 10000 -c 100 http://localhost:8080/tasks


create-task-docker:
	@echo "Creating task"
	@./create-task.sh 100 8081

bench-echo-docker:
	@echo "Benchmarking echo"
	@hey -n 10000 -c 100 http://localhost:8081/echo?name=sacré-tech

bench-tasks-docker:
	@echo "Benchmarking tasks"
	@hey -n 10000 -c 100 http://localhost:8081/tasks


build-docker:
	@echo "Building docker image"
	@docker build -t sacre-tech-go-super-power .

docker-run: # build-docker
	@echo "Running docker image"
	@docker run -p 8081:8080 sacre-tech-go-super-power