VIM_DIR = ~/.config/nvim
VIM_LUA_DIR = $(VIM_DIR)/lua
VIM_DATA_DIR = ~/.local/share/nvim
VIM_STATE_DIR = ~/.local/state/nvim
VIM_CACHE_DIR = ~/.cache/nvim
SELF_VIM_DIR = $(MODULE_DIR)/nvim
SELF_VIM_LUA_DIR = $(MODULE_DIR)/nvim/lua

NVIM_CLEAN_TARGETS += nvim-clean
NVIM_TARGETS += nvim-install

.PHONY: nvim-clean
nvim-clean:
	rm -rf $(VIM_DIR)
	rm -rf $(VIM_DATA_DIR)
	rm -rf $(VIM_STATE_DIR)
	rm -rf $(VIM_CACHE_DIR)

.PHONY: nvim-install
nvim-install: $(VIM_DIR) $(VIM_LUA_DIR)

$(VIM_DIR):
	mkdir -p $(VIM_DIR)
	ln -sf $(SELF_VIM_DIR)/init.lua $(VIM_DIR)/init.lua

$(VIM_LUA_DIR):
	ln -sfn $(SELF_VIM_LUA_DIR) $(VIM_LUA_DIR)
