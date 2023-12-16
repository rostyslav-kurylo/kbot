APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=roskurylo
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETARCH=$(shell dpkg --print-architecture)
TARGETOS=$(shell uname | tr '[:upper:]' '[:lower:]')

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: get format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}

linux: get format
	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=linux . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

windows: get format
	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=windows . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

macos: get format
	CGO_ENABLED=0 GOOS=darwin GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=macos . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

arm: get format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=arm . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	@rm -rf kbot; \
	IMG=$$(docker images -q | head -n 1); \
	if [ -n "$${IMG}" ]; then  docker rmi -f $${IMG}; else printf "$RNothing to remmove, Docker image not found!$D\n"; fi