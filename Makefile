LANGUAGES := en de
export PROJECT_ROOT_DIR := $(CURDIR)
export PROJECT_BUILD_DIR := $(PROJECT_ROOT_DIR)/build
export PROJECT_FONTS_DIR := $(PROJECT_BUILD_DIR)/fonts
export PROJECT_TEMP_DIR := $(PROJECT_BUILD_DIR)/tmp

rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
NODE = node $(PROJECT_ROOT_DIR)/node_modules/.bin/$(1)
SOURCE_PRO_PATH := node_modules/typeface-source-code-pro/files
WEBFONTS := $(patsubst $(SOURCE_PRO_PATH)/%,$(PROJECT_FONTS_DIR)/%,$(wildcard $(SOURCE_PRO_PATH)/*))
SCSS_FILES := $(call rwildcard,scss,*.scss)

.PHONY: all prepare clean server

all: $(LANGUAGES) $(WEBFONTS) $(PROJECT_BUILD_DIR)/styles.css;

clean:
	rm -rf $(PROJECT_BUILD_DIR)/*

prepare: node_modules/.timestamp
	mkdir -p $(PROJECT_BUILD_DIR)

node_modules/.timestamp: package.json
	npm i
	touch $@

server:
	npm start

$(LANGUAGES): %: prepare
	$(MAKE) --no-builtin-rules -C $@

$(WEBFONTS): $(PROJECT_FONTS_DIR)/%: $(SOURCE_PRO_PATH)/%
	mkdir -p $(dir $@)
	cp $< $@

$(PROJECT_BUILD_DIR)/styles.css: package.json $(SCSS_FILES)
	$(call NODE,node-sass) --include-path node_modules scss/styles.scss $@