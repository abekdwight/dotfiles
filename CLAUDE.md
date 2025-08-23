# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository that manages development environment configurations using a modular Make-based system. Each tool/application has its own module with dedicated Makefiles that handle installation, cleaning, and updates.

## Common Commands

### Main Operations
- `make all` - Install all configurations
- `make clean` - Remove all installed configurations
- `make update` - Update configurations where applicable

### Module-Specific Commands
- `make fish-install` / `make fish-clean` / `make fish-update` - Fish shell configuration
- `make nvim-install` / `make nvim-clean` - Neovim configuration
- `make tmux-install` / `make tmux-clean` - tmux configuration
- `make dot-install` / `make dot-clean` - Install/remove dotfiles (symlinks)

### Special Post-Install Steps
- **nvim**: After installation, run `call coc#util#install()` in nvim for coc.nvim setup
- **tmux**: Press `prefix` + `I` (where prefix is `Ctrl + q`) to install plugins

### Homebrew Package Management
- `brew bundle` - Install packages from Brewfile
- `brew bundle dump` - Backup current packages to Brewfile

## Architecture

The repository uses a modular structure where:

1. **Main Makefile** (`/Makefile`) includes all module Makefiles and defines target collections
2. **Module Directory** (`/modules/`) contains individual tool configurations, each with its own Makefile
3. **Shared Make Logic** (`/src/make/dot.mk`) handles automatic dotfile symlinking for files matching `dot.*` pattern
4. **Config Directory** (`/config/`) contains package lists for package managers

### Module Structure
Each module follows this pattern:
- Contains configuration files
- Has a dedicated Makefile with `{MODULE}_TARGETS`, `{MODULE}_CLEAN_TARGETS` variables
- Handles symlinking configurations to appropriate locations (e.g., `~/.config/`)
- May download external dependencies or plugins

### Key Bindings
- **tmux prefix**: `Ctrl + q` 
- **fish vi mode**: `Ctrl + [` to enter normal mode

## Development Notes

When modifying configurations:
- Edit files in `/modules/{tool}/` directory, not the symlinked destinations
- Use module-specific clean/install commands to test changes
- The system creates symlinks, so changes are immediately reflected