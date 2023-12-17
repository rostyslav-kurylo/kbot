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

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}

linux: format get
	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}

macos: format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}

arm: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION} --platform $${GOOS:=linux}/$${GOARCH:=amd64}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}

clean:
	@rm -rf kbot; \
	IMG=$$(docker images -q | head -n 1); \
	if [ -n "$${IMG}" ]; then  docker rmi -f $${IMG}; else printf "$RNothing to remmove, Docker image not found!$D\n"; fi