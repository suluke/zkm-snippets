NODE = node $(PROJECT_ROOT_DIR)/node_modules/.bin/$(1)
# BUILD_DIR is a special case, because en is the default site
BUILD_DIR = $(PROJECT_BUILD_DIR)
TMP := $(PROJECT_TEMP_DIR)/en
ASSETS := $(BUILD_DIR)/assets
PROG_LANG := glsl

SNIPPETS := $(wildcard snippet-*)
CODE_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/code.hbs)
JSONS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/data.json)
SNIPPETS_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/snippet.hbs)
RENAMED_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET).hbs)
PNGS := $(foreach SNIPPET,$(SNIPPETS),$(ASSETS)/$(SNIPPET).png)
QRCODES := $(foreach SNIPPET,$(SNIPPETS),$(ASSETS)/$(SNIPPET)-qr.svg)

.PHONY: all $(SNIPPETS)

all: $(BUILD_DIR)/index.html $(PNGS) $(QRCODES);

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
$(SNIPPETS_HBS): $(TMP)/%/snippet.hbs: snippet.hbs $(TMP)/%/code.hbs %/url.hbs $(TMP)/%/data.json
	mkdir -p $(dir $@)
	$(call NODE,hbs) $< -P $(@D)/code.hbs -P $*/url.hbs -D $(@D)/data.json -o $(dir $@)
	mv $(dir $@)/snippet.html $@

# A snippet's formatted code. We use prismjs to convert plain text to
# formatted html
$(CODE_HBS): $(TMP)/%/code.hbs: %/snippet
	mkdir -p $(dir $@)
	node $(PROJECT_ROOT_DIR)/tools/prism-cli -l $(PROG_LANG) -f $< -n > $@

# Sometimes it's helpful to be able to refer to the snippet's name
# (e.g. for image url's). That's what these partials are good for
$(JSONS): $(TMP)/%/data.json:
	echo '{ "name": "$*" }' > $@

# A snippet's image. Just copied over from the snippet's directory
$(PNGS): $(ASSETS)/%.png: %/image.png
	mkdir -p $(ASSETS)
	cp $< $@

# This generates a QR code in svg format
$(QRCODES): $(ASSETS)/%-qr.svg: %/url.hbs
	$(call NODE,qrcode) $$(cat $<) $@
	# We want to be able to style our svg, so add a style inclusion
	sed -i '1 a\<?xml-stylesheet href="styles.css" type="text/css"?>' $@
