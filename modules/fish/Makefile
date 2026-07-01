FISH_DIR = ~/.config/fish
FISH_COMPLETION_DIR = $(FISH_DIR)/completions
FISH_CONFIG_DIR = $(FISH_DIR)/conf.d
FISH_FUNCTION_DIR = $(FISH_DIR)/functions

SELF_FISH_DIR = $(MODULE_DIR)/fish
SELF_PRIVATE_FISH_DIR = $(TOP_DIR)-private/modules/fish

FISH_FISHER_FILE = $(FISH_FUNCTION_DIR)/fisher.fish

# define completion repos
FISH_DOCKER_COMPLETION_FILE = https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/fish/docker.fish
FISH_DOCKER_COMPOSE_COMPLETION_FILE = https://raw.githubusercontent.com/docker/compose/master/contrib/completion/fish/docker-compose.fish
FISH_FISHER_COMPLETION_FILE = https://raw.githubusercontent.com/jorgebucaran/fisher/main/completions/fisher.fish

FISH_TARGETS += fish-install
FISH_CLEAN_TARGETS += fish-clean
FISH_UPDATE_TARGETS += fish-update

.PHONY: fish-clean
fish-clean:
	rm -rf $(FISH_DIR)

.PHONY: fish-install
fish-install: $(FISH_DIR) $(FISH_FUNCTION_DIR) $(FISH_COMPLETION_DIR) $(FISH_CONFIG_DIR)

$(FISH_DIR):
	mkdir -p $(FISH_DIR)
	ln -sf $(SELF_FISH_DIR)/config.fish $(FISH_DIR)/config.fish
	ln -sf $(SELF_FISH_DIR)/fish_plugins $(FISH_DIR)/fish_plugins
	ln -sf $(SELF_FISH_DIR)/chefrepi.fish $(FISH_DIR)/chefrepi.fish

$(FISH_FUNCTION_DIR):
	mkdir -p $(FISH_FUNCTION_DIR)
	ln -sf $(SELF_FISH_DIR)/functions/fish_user_key_bindings.fish $(FISH_FUNCTION_DIR)/fish_user_key_bindings.fish
	ln -sf $(SELF_FISH_DIR)/functions/ghq_all.fish $(FISH_FUNCTION_DIR)/ghq_all.fish
	ln -sf $(SELF_FISH_DIR)/functions/ghq_all_orgs.fish $(FISH_FUNCTION_DIR)/ghq_all_orgs.fish
	ln -sf $(SELF_FISH_DIR)/functions/ghq_remove_all.fish $(FISH_FUNCTION_DIR)/ghq_remove_all.fish
	ln -sf $(SELF_FISH_DIR)/functions/logo.fish $(FISH_FUNCTION_DIR)/logo.fish
	ln -sf $(SELF_FISH_DIR)/functions/netatmo.fish $(FISH_FUNCTION_DIR)/netatmo.fish
	ln -sf $(SELF_FISH_DIR)/functions/peco_ghq.fish $(FISH_FUNCTION_DIR)/peco_ghq.fish
	ln -sf $(SELF_FISH_DIR)/functions/peco_kill.fish $(FISH_FUNCTION_DIR)/peco_kill.fish
	ln -sf $(SELF_FISH_DIR)/functions/peco_select_history.fish $(FISH_FUNCTION_DIR)/peco_select_history.fish
	ln -sf $(SELF_FISH_DIR)/functions/peco_z.fish $(FISH_FUNCTION_DIR)/peco_z.fish
	ln -sf $(SELF_FISH_DIR)/functions/peco_tmux.fish $(FISH_FUNCTION_DIR)/peco_tmux.fish
	ln -sf $(SELF_FISH_DIR)/functions/mdm.fish $(FISH_FUNCTION_DIR)/mdm.fish
	ln -sf $(SELF_FISH_DIR)/functions/prco_nodebrew.fish $(FISH_FUNCTION_DIR)/prco_nodebrew.fish
	ln -sf $(SELF_FISH_DIR)/functions/prco_phpbrew.fish $(FISH_FUNCTION_DIR)/prco_phpbrew.fish
	ln -sf $(SELF_FISH_DIR)/functions/tmux_attach_session_if_needed.fish $(FISH_FUNCTION_DIR)/tmux_attach_session_if_needed.fish
	ln -sf $(SELF_FISH_DIR)/functions/tmux_start_ephemeral_session.fish $(FISH_FUNCTION_DIR)/tmux_start_ephemeral_session.fish
	curl https://git.io/fisher --create-dirs -sLo $(FISH_FISHER_FILE)

$(FISH_COMPLETION_DIR):
	mkdir -p $(FISH_COMPLETION_DIR)
	curl $(FISH_DOCKER_COMPLETION_FILE) -o $(FISH_COMPLETION_DIR)/docker.fish
	curl $(FISH_DOCKER_COMPOSE_COMPLETION_FILE) -o $(FISH_COMPLETION_DIR)/docker-compose.fish
	curl $(FISH_FISHER_COMPLETION_FILE) -o $(FISH_COMPLETION_DIR)/fisher.fish
	ln -sf $(SELF_FISH_DIR)/completions/ecschedule.fish $(FISH_COMPLETION_DIR)/ecschedule.fish


$(FISH_CONFIG_DIR):
	mkdir -p $(FISH_CONFIG_DIR)
	ln -sf $(SELF_FISH_DIR)/conf.d/fish.fish $(FISH_CONFIG_DIR)/fish.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/go.fish $(FISH_CONFIG_DIR)/go.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/mac.fish $(FISH_CONFIG_DIR)/mac.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/nix.fish $(FISH_CONFIG_DIR)/nix.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/node.fish $(FISH_CONFIG_DIR)/node.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/python.fish $(FISH_CONFIG_DIR)/python.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/php.fish $(FISH_CONFIG_DIR)/php.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/ruby.fish $(FISH_CONFIG_DIR)/ruby.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/rust.fish $(FISH_CONFIG_DIR)/rust.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/shell.fish $(FISH_CONFIG_DIR)/shell.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/starship.fish $(FISH_CONFIG_DIR)/starship.fish
	ln -sf $(SELF_FISH_DIR)/conf.d/tex.fish $(FISH_CONFIG_DIR)/tex.fish

fish-update:
	fish -c "fisher update"
