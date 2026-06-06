require('neo-tree').setup({
  close_if_last_window = true,
  popup_border_style = 'rounded',
  enable_git_status = true,
  enable_diagnostics = true,
  default_component_configs = {
    indent = {
      with_expanders = true,
      expander_collapsed = '',
      expander_expanded = '',
      expander_highlight = 'NeoTreeExpander',
    },
    icon = {
      provider = function(icon, node)
        local mini_icons = require('mini.icons')
        local text, hl

        if node.type == 'file' then
          text, hl = mini_icons.get('file', node:get_id())
        elseif node.type == 'directory' then
          if node:is_expanded() then
            text = nil
          else
            text, hl = mini_icons.get('directory', node.name)
          end
        elseif node.type == 'terminal' then
          text, hl = mini_icons.get('file', 'terminal')
        end

        icon.text = text or icon.text
        icon.highlight = hl or icon.highlight
      end,
    },
    git_status = {
      symbols = {
        added     = '✚',
        deleted   = '✖',
        modified  = '',
        renamed   = '󰁕',
        untracked = '',
        ignored   = '',
        unstaged  = '󰄱',
        staged    = '',
        conflict  = '',
      },
    },
  },
  window = {
    position = 'right',
    width = 40,
    mapping_options = {
      noremap = true,
      nowait = true,
    },
    mappings = {
      ['<CR>'] = 'open',
      ['o'] = 'open',
      ['l'] = 'open',
      ['<C-v>'] = 'open_vsplit',
      ['<C-x>'] = 'open_split',
      ['q'] = 'close_window',
      ['R'] = 'refresh',
      ['<'] = 'prev_source',
      ['>'] = 'next_source',
      ['P'] = {
        'toggle_preview',
        config = {
          use_float = false,
        },
      },
    },
  },
  filesystem = {
    window = {
      mappings = {
        ['h'] = 'close_node',
        ['a'] = { 'add', config = { show_path = 'relative' } },
        ['A'] = 'add_directory',
        ['d'] = 'delete',
        ['r'] = 'rename',
        ['y'] = 'copy_to_clipboard',
        ['x'] = 'cut_to_clipboard',
        ['p'] = 'paste_from_clipboard',
        ['c'] = 'copy',
        ['m'] = 'move',
        ['/'] = 'fuzzy_finder',
        ['-'] = 'navigate_up',
        ['.'] = 'set_root',
        ['H'] = 'toggle_hidden',
        ['I'] = 'toggle_gitignore',
        ['W'] = 'close_all_nodes',
      },
    },
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_by_name = {
        '.git',
        '.DS_Store',
      },
      never_show = {},
    },
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },
    use_libuv_file_watcher = true,
  },
  git_status = {
    window = {
      mappings = {
        ['h'] = 'close_node',
        ['u'] = 'git_toggle_file_stage',
      },
    },
  },
  source_selector = {
    winbar = true,
    sources = {
      { source = 'filesystem', display_name = ' Files ' },
      { source = 'buffers', display_name = ' Buffers ' },
      { source = 'git_status', display_name = ' Git ' },
    },
  },
})
