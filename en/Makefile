NODE = node $(PROJECT_ROOT_DIR)/node_modules/.bin/$(1)
# BUILD_DIR is a special case, because en is the default site
BUILD_DIR = $(PROJECT_BUILD_DIR)
TMP := $(PROJECT_TEMP_DIR)/en
ASSETS := $(BUILD_DIR)/assets
PROG_LANG := glsl

SNIPPETS := $(wildcard snippet-*)
CODE_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/code.hbs)
SNIPPETS_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/snippet.hbs)
RENAMED_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET).hbs)
PNGS := $(foreach SNIPPET,$(SNIPPETS),$(ASSETS)/$(SNIPPET).png)

.PHONY: all $(SNIPPETS)

all: $(BUILD_DIR)/index.html $(PNGS) ;

# The page. Depends on the page template and the available snippets 
$(BUILD_DIR)/index.html: index.hbs $(RENAMED_HBS)
	$(call NODE,hbs) $< $(foreach SHBS,$(RENAMED_HBS),-P $(SHBS)) -o $(BUILD_DIR)

# Snippets. Each snippet consists of its html code (.hbs partial) and
# the image showing the code snippet's effect
$(SNIPPETS): %: $(TMP)/%.hbs $(ASSETS)/%.png ;

# When used as a partial, we actually need unique *file* names (paths
# don't suffice), such as snippet-1.hbs. Therefore we need to create those
# in an extra step.
$(RENAMED_HBS): $(TMP)/%.hbs: $(TMP)/%/snippet.hbs
	cp $< $@

# A snippet's hbs partial. Will be generated from the general snippet
# template, the snippet's formatted code and the github url to the snippet.
$(SNIPPETS_HBS): $(TMP)/%/snippet.hbs: snippet.hbs $(TMP)/%/code.hbs %/url.hbs
	mkdir -p $(dir $@)
	$(call NODE,hbs) $< -P $(@D)/code.hbs -P $*/url.hbs -o $(dir $@)
	mv $(dir $@)/snippet.html $@

# A snippet's formatted code. We use prismjs to convert plain text to
# formatted html
$(CODE_HBS): $(TMP)/%/code.hbs: %/snippet
	mkdir -p $(dir $@)
	node $(PROJECT_ROOT_DIR)/tools/prism-cli -l $(PROG_LANG) -f $< -n > $@

# A snippet's image. Just copied over from the snippet's directory
$(ASSETS)/%.png: %/image.png
	mkdir -p $(ASSETS)
	cp $< $@