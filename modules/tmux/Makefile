TMUX_PLUGIN_DIR = ~/.tmux/plugins
TMUX_DIR = $(TMUX_PLUGIN_DIR)/tpm
TMUX_GITHUB_URL = https://github.com/tmux-plugins/tpm
TMUX_OPEN_MD_PLUGIN_DIR = $(TMUX_PLUGIN_DIR)/tmux-open-md
SELF_TMUX_DIR = $(MODULE_DIR)/tmux

TMUX_CLEAN_TARGETS += tmux-clean
TMUX_TARGETS += tmux-install

.PHONY: tmux-clean
tmux-clean:
	rm -fr $(TMUX_DIR)
	rm -fr $(TMUX_OPEN_MD_PLUGIN_DIR)

tmux-install: $(TMUX_DIR) $(TMUX_OPEN_MD_PLUGIN_DIR)

$(TMUX_PLUGIN_DIR):
	mkdir -p $(TMUX_PLUGIN_DIR)

$(TMUX_DIR): $(TMUX_PLUGIN_DIR)
	git clone --depth=1 $(TMUX_GITHUB_URL) $(TMUX_DIR)

$(TMUX_OPEN_MD_PLUGIN_DIR): $(TMUX_PLUGIN_DIR)
	rm -rf $(TMUX_OPEN_MD_PLUGIN_DIR)
	ln -s $(SELF_TMUX_DIR)/plugins/tmux-open-md $(TMUX_OPEN_MD_PLUGIN_DIR)
