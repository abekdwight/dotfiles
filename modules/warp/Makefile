WARP_DIR = ~/.warp
WARP_TAB_CONFIGS_DIR = $(WARP_DIR)/tab_configs
SELF_WARP_DIR = $(MODULE_DIR)/warp

WARP_CLEAN_TARGETS += warp-clean
WARP_TARGETS += warp-install

.PHONY: warp-install
warp-install: $(WARP_DIR) $(WARP_TAB_CONFIGS_DIR)
	ln -sf $(SELF_WARP_DIR)/settings.toml $(WARP_DIR)/settings.toml
	ln -sf $(SELF_WARP_DIR)/keybindings.yaml $(WARP_DIR)/keybindings.yaml
	ln -sf $(SELF_WARP_DIR)/tab_configs/startup_config.toml $(WARP_TAB_CONFIGS_DIR)/startup_config.toml
	ln -sf $(SELF_WARP_DIR)/tab_configs/startup_config_1.toml $(WARP_TAB_CONFIGS_DIR)/startup_config_1.toml

$(WARP_DIR):
	mkdir -p $(WARP_DIR)

$(WARP_TAB_CONFIGS_DIR):
	mkdir -p $(WARP_TAB_CONFIGS_DIR)

.PHONY: warp-clean
warp-clean:
	rm -f $(WARP_DIR)/settings.toml
	rm -f $(WARP_DIR)/keybindings.yaml
	rm -f $(WARP_TAB_CONFIGS_DIR)/startup_config.toml
	rm -f $(WARP_TAB_CONFIGS_DIR)/startup_config_1.toml
