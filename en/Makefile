NODE = node $(PROJECT_ROOT_DIR)/node_modules/.bin/$(1)
# BUILD_DIR is a special case, because en is the default site
BUILD_DIR = $(PROJECT_BUILD_DIR)
TMP := $(PROJECT_TEMP_DIR)/en
ASSETS := $(BUILD_DIR)/assets

SNIPPETS := $(sort $(wildcard snippet-*))
CODE_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/code.hbs)
JSONS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/data.json)
SNIPPETS_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/snippet.hbs)
RENAMED_HBS := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET).hbs)
PNGS := $(foreach SNIPPET,$(SNIPPETS),$(ASSETS)/$(SNIPPET).png)
QRCODES := $(foreach SNIPPET,$(SNIPPETS),$(TMP)/$(SNIPPET)/qr.svg.hbs)
ALL_SNIPPETS := $(foreach SNIPPET,$(SNIPPETS),{{> $(SNIPPET) }}\
)
# This needs to end with slash if it's not empty
PATH_TO_ROOT :=

.PHONY: all $(SNIPPETS)

all: $(BUILD_DIR)/index.html $(PNGS);

# The page. Depends on the page template and the available snippets 
$(BUILD_DIR)/index.html: index.hbs $(TMP)/snippets.hbs $(RENAMED_HBS) $(TMP)/page.json
	$(call NODE,hbs) $< -P $(TMP)/snippets.hbs $(foreach SHBS,$(RENAMED_HBS),-P $(SHBS)) -D $(TMP)/page.json -o $(BUILD_DIR)

$(TMP)/page.json:
	 echo '{"page-root": "$(PATH_TO_ROOT)"}' > $@

# This rule generates a partial that simply includes all the other snippet
# partials, so that we don't have to maintain this index manually
$(TMP)/snippets.hbs: $(RENAMED_HBS)
	echo "$(ALL_SNIPPETS)" > $@

# When used as a partial, we actually need unique *file* names (paths
# don't suffice), such as snippet-1.hbs. Therefore we need to create those
# in an extra step.
$(RENAMED_HBS): $(TMP)/%.hbs: $(TMP)/%/snippet.hbs
	cp $< $@

# A snippet's hbs partial. Will be generated from the general snippet
# template, the snippet's formatted code and the github url to the snippet.
# Additionally, the partial gets passed some data (like the snippet's name)
# over JSON.
$(SNIPPETS_HBS): $(TMP)/%/snippet.hbs: snippet.hbs $(TMP)/%/code.hbs %/info.json $(TMP)/%/qr.svg.hbs $(TMP)/%/data.json $(TMP)/page.json
	mkdir -p $(dir $@)
	$(call NODE,hbs) $< -P $(@D)/code.hbs -D $*/info.json -P $(@D)/qr.svg.hbs -D $(@D)/data.json -D $(TMP)/page.json -o $(dir $@)
	mv $(dir $@)/snippet.html $@

# A snippet's formatted code. We use prismjs to convert plain text to
# formatted html
$(CODE_HBS): $(TMP)/%/code.hbs: %/snippet %/info.json
	mkdir -p $(dir $@)
	node $(PROJECT_ROOT_DIR)/tools/prism-cli -l $$($(call NODE,json) -f $*/info.json language) -f $< -n -o $@

# Sometimes it's helpful to be able to refer to the snippet's name
# (e.g. for image url's). That's what these JSON files are good for.
$(JSONS): $(TMP)/%/data.json:
	echo '{ "name": "$*" }' > $@

# A snippet's image. Just copied over from the snippet's directory
$(PNGS): $(ASSETS)/%.png: %/image.png
	mkdir -p $(ASSETS)
	cp $< $@

# This generates a QR code in svg format
$(QRCODES): $(TMP)/%/qr.svg.hbs: %/info.json
	$(call NODE,qrcode) "$$($(call NODE,json) -f $< url)" $(dir $@)/qr.svg
	mv $(dir $@)/qr.svg $@
