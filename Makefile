BUILD_DIR = $(PWD)/build
SHELL = bash

ROOTFS = $(BUILD_DIR)/rootfs

TARGET_KERNEL = $(BUILD_DIR)/bzImage

all: $(TARGET_KERNEL) $(BUILD_DIR)/initrd.img.gz

$(BUILD_DIR) $(ROOTFS):
	@mkdir -p $@

export BUILD_DIR

$(TARGET_KERNEL): $(BUILD_DIR)
	$(MAKE) -f build-k.mk kernel

# Use any rootfs subdir as target
$(ROOTFS)/bin: $(BUILD_DIR) $(ROOTFS)
	$(MAKE) -f build-u.mk user

$(BUILD_DIR)/initrd.img.gz: $(ROOTFS)/bin
	$(SHELL) minimal_initrd.sh $(ROOTFS) $@

k: $(TARGET_KERNEL)
u: $(ROOTFS)/bin
i: $(BUILD_DIR)/initrd.img.gz

QEMU ?= qemu-system-x86_64
QEMU_OPTS += \
	-kernel $(TARGET_KERNEL) \
	-initrd $(BUILD_DIR)/initrd.img.gz \
	-append "root=/dev/ram0 init=/init console=ttyS0" \
	-nographic

qemu:
	$(QEMU) $(QEMU_OPTS)

# Change create_gdb_scripts.sh manually to debug kernel
$(BUILD_DIR)/.gdbinit:
	$(SHELL) create_gdb_scripts.sh

qemu-gdb: $(BUILD_DIR)/.gdbinit
	$(QEMU) $(QEMU_OPTS) -s -S

.PHONY: clean

clean:
	$(MAKE) -f build-u.mk clean
	$(MAKE) -f build-k.mk clean
	rm -rf $(BUILD_DIR)
