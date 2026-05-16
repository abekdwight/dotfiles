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

.PHONY: nvim-command-palette-candidates
nvim-command-palette-candidates:
	XDG_CONFIG_HOME=$(MODULE_DIR) nvim --headless +'lua local ok, err = pcall(function() require("config.command_palette_core").write_source_file() end); if not ok then print(err); vim.cmd("cquit") end' +qa

.PHONY: nvim-command-palette-source
nvim-command-palette-source: nvim-command-palette-candidates

.PHONY: nvim-command-palette-coverage
nvim-command-palette-coverage:
	XDG_CONFIG_HOME=$(MODULE_DIR) nvim --headless +'lua local ok, result = pcall(function() return require("config.command_palette_core").print_coverage() end); if not ok then print(result); vim.cmd("cquit") end; if not result then vim.cmd("cquit") end' +qa

$(VIM_DIR):
	mkdir -p $(VIM_DIR)
	ln -sf $(SELF_VIM_DIR)/init.lua $(VIM_DIR)/init.lua

$(VIM_LUA_DIR):
	ln -sfn $(SELF_VIM_LUA_DIR) $(VIM_LUA_DIR)
