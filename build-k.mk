
BUILD_DIR ?= $(PWD)
DOCKER ?= docker

$(OUT_DIR_BB):
	mkdir -p $(OUT_DIR_BB)


TARGET_KERNEL = linux-2.6.32.40
K_SOURCES_DIR = $(PWD)/$(TARGET_KERNEL)
K_IMAGE ?= bzImage
K_VMLINUX ?= vmlinux

kernel-builder-old:
	$(DOCKER) build -t kernel-builder-old .

guest-build-commands = "cd /kernel/$(TARGET_KERNEL) && \
	make mrproper && \
	make defconfig && \
	scripts/config --enable DEBUG_INFO && \
	make -j4"

guest-clean-commands = "cd /kernel/$(TARGET_KERNEL) && \
	make mrproper"

# Build kernel on guest VM using sources from host's K_SOURCES_DIR
kernel: kernel-builder-old
	$(DOCKER) run --name kernel-build-tmp -v $(K_SOURCES_DIR):/kernel/$(TARGET_KERNEL) kernel-builder-old bash -c $(guest-build-commands)
	$(DOCKER) cp kernel-build-tmp:/kernel/$(TARGET_KERNEL)/arch/x86/boot/bzImage $(BUILD_DIR)/$(K_IMAGE)
	$(DOCKER) cp kernel-build-tmp:/kernel/$(TARGET_KERNEL)/$(K_VMLINUX) $(BUILD_DIR)/$(K_VMLINUX)
	$(DOCKER) rm kernel-build-tmp
	@echo "========== DONE =========="
	@echo "Kernel image: $(BUILD_DIR)/$(K_IMAGE)"

# Clean source tree on guest
clean-sources:
	docker run --rm -v $(K_SOURCES_DIR):/kernel/$(TARGET_KERNEL) kernel-builder-old bash -c $(guest-clean-commands)
	@echo "Guest VM mrpropered"

# Clean all
clean:
	docker ps -a --filter "ancestor=kernel-builder-old" -q | xargs -r docker rm -f
	rm -f $(BUILD_DIR)/$(K_IMAGE)
