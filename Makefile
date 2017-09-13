LANGUAGES := en de
export PROJECT_ROOT_DIR := $(CURDIR)
export PROJECT_BUILD_DIR := $(PROJECT_ROOT_DIR)/build
export PROJECT_TEMP_DIR := $(PROJECT_BUILD_DIR)/tmp

.PHONY: all prepare clean

all: $(LANGUAGES) ;

clean:
	rm -rf $(PROJECT_BUILD_DIR)/*

prepare:
	echo Node: $(NODE)
	mkdir -p $(PROJECT_BUILD_DIR)

$(LANGUAGES): %: prepare
	$(MAKE) --no-builtin-rules -C $@
