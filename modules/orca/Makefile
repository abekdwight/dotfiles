ORCA_DIR = ~/.orca
SELF_ORCA_DIR = $(MODULE_DIR)/orca

ORCA_CLEAN_TARGETS += orca-clean
ORCA_TARGETS += orca-install

.PHONY: orca-install
orca-install: $(ORCA_DIR)
	ln -sf $(SELF_ORCA_DIR)/keybindings.json $(ORCA_DIR)/keybindings.json

$(ORCA_DIR):
	mkdir -p $(ORCA_DIR)

.PHONY: orca-clean
orca-clean:
	rm -f $(ORCA_DIR)/keybindings.json
