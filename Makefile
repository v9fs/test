.PHONY: docker-smoke

IMAGE ?= ghcr.io/v9fs/docker:latest
KERNEL_RELEASE ?= kernel-main

docker-smoke:
	mkdir -p ./tmp ./kernel
	@echo "Place kernel Image at ./kernel/.build/arch/arm64/boot/Image (or download from release $(KERNEL_RELEASE))"
	docker run --rm --privileged \
	  -e KERNELBUILD=/workspaces/kernel/.build \
	  -v "$$(pwd):/home/v9fs-test/test" \
	  -v "$$(pwd)/kernel:/workspaces/kernel" \
	  -v "$$(pwd)/tmp:/workspaces/tmp" \
	  -w /home/v9fs-test/test \
	  $(IMAGE) \
	  bash -lc "./scripts/v9fs-run-tests smoke"

