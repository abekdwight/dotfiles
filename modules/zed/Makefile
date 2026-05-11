ZED_DIR = ~/.config/zed
SELF_ZED_DIR = $(MODULE_DIR)/zed

ZED_CLEAN_TARGETS += zed-clean
ZED_TARGETS += zed-install

.PHONY: zed-install
zed-install: $(ZED_DIR)
	ln -sf $(SELF_ZED_DIR)/settings.json $(ZED_DIR)/settings.json
	ln -sf $(SELF_ZED_DIR)/keymap.json $(ZED_DIR)/keymap.json

$(ZED_DIR):
	mkdir -p $(ZED_DIR)

.PHONY: zed-clean
zed-clean:
	rm -f $(ZED_DIR)/settings.json
	rm -f $(ZED_DIR)/keymap.json
