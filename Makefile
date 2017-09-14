LANGUAGES := en de
export PROJECT_ROOT_DIR := $(CURDIR)
export PROJECT_BUILD_DIR := $(PROJECT_ROOT_DIR)/build
export PROJECT_FONTS_DIR := $(PROJECT_BUILD_DIR)/fonts
export PROJECT_TEMP_DIR := $(PROJECT_BUILD_DIR)/tmp

SOURCE_PRO_PATH := node_modules/typeface-source-code-pro/files
WEBFONTS := $(patsubst $(SOURCE_PRO_PATH)/%,$(PROJECT_FONTS_DIR)/%,$(wildcard $(SOURCE_PRO_PATH)/*))

.PHONY: all prepare clean

all: $(LANGUAGES) $(WEBFONTS) ;

clean:
	rm -rf $(PROJECT_BUILD_DIR)/*

prepare: node_modules
	mkdir -p $(PROJECT_BUILD_DIR)

node_modules: package.json
	npm i

$(LANGUAGES): %: prepare
	$(MAKE) --no-builtin-rules -C $@

$(WEBFONTS): $(PROJECT_FONTS_DIR)/%: $(SOURCE_PRO_PATH)/%
	mkdir -p $(dir $@)
	cp $< $@
