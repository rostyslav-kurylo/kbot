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
	docker build --build-arg name=linux . -t ${REGISTRY}/${APP}:${VERSION}-linux-${TARGETARCH}

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=windows . -t ${REGISTRY}/${APP}:${VERSION}-windows-${TARGETARCH}

macos: format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=macos . -t ${REGISTRY}/${APP}:${VERSION}-macos-${TARGETARCH}

arm: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=arm . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-arm

image: build
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi -f $(shell docker images -q | head -n 1)