VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETARCH=$(shell dpkg --print-architecture)
TARGETOS=linux

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/rostyslav-kurylo/kbot/cmd.appVersion=${VERSION}

clean:
	rm -rf kbot