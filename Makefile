.PHONY: docker-build docker-smoke

IMAGE ?= v9fs-test-env:local
KERNEL_RELEASE ?= kernel-main

docker-build:
	docker build -t $(IMAGE) .

docker-smoke: docker-build
	mkdir -p ./tmp ./kernel
	@echo "Place kernel Image at ./kernel/.build/arch/arm64/boot/Image (or download from release $(KERNEL_RELEASE))"
	docker run --rm --privileged \
	  -e KERNELBUILD=/workspaces/kernel/.build \
	  -v "$$(pwd):/home/v9fs-test/test" \
	  -v "$$(pwd)/kernel:/workspaces/kernel" \
	  -v "$$(pwd)/tmp:/workspaces/tmp" \
	  -w /home/v9fs-test/test \
	  $(IMAGE) \
	  bash -lc "v9fs-run-tests smoke"

