# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gcnc android ios gcnc-cross evm all test clean
.PHONY: gcnc-linux gcnc-linux-386 gcnc-linux-amd64 gcnc-linux-mips64 gcnc-linux-mips64le
.PHONY: gcnc-linux-arm gcnc-linux-arm-5 gcnc-linux-arm-6 gcnc-linux-arm-7 gcnc-linux-arm64
.PHONY: gcnc-darwin gcnc-darwin-386 gcnc-darwin-amd64
.PHONY: gcnc-windows gcnc-windows-386 gcnc-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gcnc:
	build/env.sh go run build/ci.go install ./cmd/gcnc
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gcnc\" to launch gcnc."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gcnc.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gcnc.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gcnc-cross: gcnc-linux gcnc-darwin gcnc-windows gcnc-android gcnc-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-*

gcnc-linux: gcnc-linux-386 gcnc-linux-amd64 gcnc-linux-arm gcnc-linux-mips64 gcnc-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-*

gcnc-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gcnc
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep 386

gcnc-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gcnc
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep amd64

gcnc-linux-arm: gcnc-linux-arm-5 gcnc-linux-arm-6 gcnc-linux-arm-7 gcnc-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep arm

gcnc-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gcnc
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep arm-5

gcnc-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gcnc
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep arm-6

gcnc-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gcnc
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep arm-7

gcnc-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gcnc
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep arm64

gcnc-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gcnc
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep mips

gcnc-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gcnc
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep mipsle

gcnc-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gcnc
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep mips64

gcnc-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gcnc
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-linux-* | grep mips64le

gcnc-darwin: gcnc-darwin-386 gcnc-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-darwin-*

gcnc-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gcnc
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-darwin-* | grep 386

gcnc-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gcnc
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-darwin-* | grep amd64

gcnc-windows: gcnc-windows-386 gcnc-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-windows-*

gcnc-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gcnc
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-windows-* | grep 386

gcnc-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gcnc
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gcnc-windows-* | grep amd64
