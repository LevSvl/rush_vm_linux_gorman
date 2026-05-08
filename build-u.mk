BUILD_DIR ?= $(PWD)

CC=gcc

###
### This part used to build busybox
###

TARGET_BB = busybox
OUT_DIR_BB = $(BUILD_DIR)/rootfs
LDFLAGS_BB += --static

$(OUT_DIR_BB) $(OUT_DIR_CSTM):
	mkdir -p $@

$(TARGET_BB)/busybox_unstripped: $(TARGET_BB) $(OUT_DIR_BB)
	$(MAKE) -C $(TARGET_BB) defconfig
	@sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' $(TARGET_BB)/.config
	$(MAKE) -C $(TARGET_BB) -j4 EXTRA_LDFLAGS=$(LDFLAGS_BB) \
		CONFIG_PREFIX=$(OUT_DIR_BB) SKIP_STRIP=y install


###
### This part used to build custom userspace programs
###

CUSTOM_SRC_DIR = custom
CUSTOM_SUBDIRS = $(shell ls $(CUSTOM_SRC_DIR))
OUT_DIR_CSTM = $(BUILD_DIR)/custom

CUSTOM_CCFLAGS += -Wall -g

# gen-custom-rule called for each subdir in CUSTOM_SRC_DIR
define gen-custom-rule

TARGET_DIR:= $(OUT_DIR_CSTM)/$(1)
TARGET_SRC := $(wildcard $(CUSTOM_SRC_DIR)/$(1)/*.c)
TARGET_ELF := $$(TARGET_DIR)/_main

$$(TARGET_DIR):
	@mkdir $$@

$$(TARGET_ELF): $$(TARGET_DIR) $$(TARGET_SRC)
	$${CC} $${CUSTOM_CCFLAGS} -static $$(TARGET_SRC) -o $$@

endef # gen-custom-rule

$(foreach dir,$(CUSTOM_SUBDIRS),$(eval $(call gen-custom-rule,$(dir))))

###
### This part used to copy custom userspace programs into rootfs
###

$(OUT_DIR_BB)/custom:
	@mkdir $@

$(OUT_DIR_BB)/custom/%: $(OUT_DIR_CSTM)/%/_main
	@cp $< $@


CUSTOM_TARGETS_IN_ROOTFS = $(foreach target,\
	$(CUSTOM_SUBDIRS),$(OUT_DIR_BB)/custom/$(target))

###
### Common rule to get all userspace programs
###
user: $(TARGET_BB)/busybox_unstripped $(OUT_DIR_BB)/custom $(CUSTOM_TARGETS_IN_ROOTFS)


clean:
	$(MAKE) -C $(TARGET_BB) distclean
	rm -rf $(OUT_DIR_BB) $(OUT_DIR_BB)/custom $(OUT_DIR_CSTM)
