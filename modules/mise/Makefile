MISE_CONFIG_DIR = ~/.config/mise
MISE_CONFIG_FILE = $(MISE_CONFIG_DIR)/config.toml
SELF_MISE_DIR = $(MODULE_DIR)/mise

MISE_TARGETS += mise-install
MISE_CLEAN_TARGETS += mise-clean

.PHONY: mise-install
mise-install: $(MISE_CONFIG_DIR)
	ln -sf $(SELF_MISE_DIR)/config.toml $(MISE_CONFIG_FILE)

$(MISE_CONFIG_DIR):
	mkdir -p $(MISE_CONFIG_DIR)

.PHONY: mise-clean
mise-clean:
	rm -f $(MISE_CONFIG_FILE)
