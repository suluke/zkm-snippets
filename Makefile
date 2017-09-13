LANGUAGES := en de
export PROJECT_ROOT := $(CURDIR)
export BUILD_DIR := $(PROJECT_ROOT)/build

.PHONY: all prepare

all: $(LANGUAGES);

prepare:
	mkdir -p $(BUILD_DIR)

$(LANGUAGES): %: prepare
	$(MAKE) -C $@
