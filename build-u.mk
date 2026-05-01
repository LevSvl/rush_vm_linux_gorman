BUILD_DIR ?= $(PWD)

TARGET_BB = busybox

OUT_DIR_BB = $(BUILD_DIR)/rootfs
LDFLAGS_BB += --static

$(OUT_DIR_BB):
	mkdir -p $(OUT_DIR_BB)

user: $(TARGET_BB) $(OUT_DIR_BB)	
	$(MAKE) -C $(TARGET_BB) defconfig
	@sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' $(TARGET_BB)/.config
	$(MAKE) -C $(TARGET_BB) -j4 EXTRA_LDFLAGS=$(LDFLAGS_BB) \
		CONFIG_PREFIX=$(OUT_DIR_BB) SKIP_STRIP=y install

clean:
	$(MAKE) -C $(TARGET_BB) distclean
	rm -rf $(OUT_DIR_BB)
