CMUX_DIR = ~/.config/cmux
SELF_CMUX_DIR = $(MODULE_DIR)/cmux

CMUX_CLEAN_TARGETS += cmux-clean
CMUX_TARGETS += cmux-install

.PHONY: cmux-install
cmux-install: $(CMUX_DIR)
	ln -sf $(SELF_CMUX_DIR)/cmux.json $(CMUX_DIR)/cmux.json

$(CMUX_DIR):
	mkdir -p $(CMUX_DIR)

.PHONY: cmux-clean
cmux-clean:
	rm -f $(CMUX_DIR)/cmux.json
