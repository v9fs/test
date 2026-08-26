.PHONY: docker-smoke docker-tail-follow tail-follow-selftest docker-clean docker-clean-aggressive

IMAGE ?= ghcr.io/v9fs/docker:latest
KERNEL_RELEASE ?= kernel-main
DOCKER ?= docker

# Issue #3 unit test with no QEMU/9p. Validates inotify/stat/tail watchers.
# No Docker, no kernel: run this while iterating on scripts/v9fs-tail-follow.
tail-follow-selftest:
	python3 ./scripts/v9fs-tail-follow selftest

# Issue #3 repro against virtio-9p (and diod if the image has it).
# Independent of the CI matrix. Requires arm64 Image at kernel/.build/arch/arm64/boot/Image.
# Use DOCKER=podman when the docker socket is unavailable.
docker-tail-follow:
	mkdir -p ./tmp ./kernel
	@echo "Place kernel Image at ./kernel/.build/arch/arm64/boot/Image (or download from release $(KERNEL_RELEASE))"
	@set -euo pipefail; \
	  name="v9fs-test.tail-follow.$$(date +%s)"; \
	  mkdir -p logs/docker; \
	  echo "Running container $$name"; \
	  set +e; \
	  $(DOCKER) run --privileged \
	    --name "$$name" \
	    --label v9fs.harness=v9fs-test \
	    --user 0:0 \
	    -e KERNELBUILD=/workspaces/kernel/.build \
	    -v "$$(pwd):/home/v9fs-test/test" \
	    -v "$$(pwd)/kernel:/workspaces/kernel" \
	    -v "$$(pwd)/tmp:/workspaces/tmp" \
	    -w /home/v9fs-test/test \
	    $(IMAGE) \
	    bash -lc "./scripts/v9fs-run-tests tail-follow"; \
	  rc="$$?"; \
	  set -e; \
	  $(DOCKER) logs "$$name" >"logs/docker/$${name}.log" 2>&1 || true; \
	  $(DOCKER) inspect "$$name" >"logs/docker/$${name}.inspect.json" 2>&1 || true; \
	  $(DOCKER) rm -f "$$name" >/dev/null 2>&1 || true; \
	  echo "Saved docker logs to logs/docker/$${name}.log"; \
	  if [ -f logs/tail-follow.report.json ]; then echo "---- tail-follow.report.json ----"; cat logs/tail-follow.report.json; fi; \
	  exit "$$rc"

docker-smoke:
	mkdir -p ./tmp ./kernel
	@echo "Place kernel Image at ./kernel/.build/arch/arm64/boot/Image (or download from release $(KERNEL_RELEASE))"
	@set -euo pipefail; \
	  name="v9fs-test.smoke.$$(date +%s)"; \
	  mkdir -p logs/docker; \
	  echo "Running container $$name"; \
	  set +e; \
	  docker run --privileged \
	    --name "$$name" \
	    --label v9fs.harness=v9fs-test \
	    --user 0:0 \
	    -e KERNELBUILD=/workspaces/kernel/.build \
	    -v "$$(pwd):/home/v9fs-test/test" \
	    -v "$$(pwd)/kernel:/workspaces/kernel" \
	    -v "$$(pwd)/tmp:/workspaces/tmp" \
	    -w /home/v9fs-test/test \
	    $(IMAGE) \
	    bash -lc "./scripts/v9fs-run-tests smoke"; \
	  rc="$$?"; \
	  set -e; \
	  docker logs "$$name" >"logs/docker/$${name}.log" 2>&1 || true; \
	  docker inspect "$$name" >"logs/docker/$${name}.inspect.json" 2>&1 || true; \
	  docker rm -f "$$name" >/dev/null 2>&1 || true; \
	  echo "Saved docker logs to logs/docker/$${name}.log"; \
	  exit "$$rc"

docker-clean:
	@echo "Cleaning containers labeled v9fs.harness=v9fs-test"
	@docker ps -aq --filter "label=v9fs.harness=v9fs-test" | xargs -r docker rm -f >/dev/null 2>&1 || true

docker-clean-aggressive:
	@./scripts/v9fs-docker-clean --aggressive

