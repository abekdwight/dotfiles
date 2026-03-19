local use_nerd_font = vim.g.use_nerd_font ~= false

require('mini.icons').setup({
  style = use_nerd_font and 'glyph' or 'ascii',
})

require('mini.statusline').setup({
  use_icons = use_nerd_font,
})

require('mini.tabline').setup()

require('mini.notify').setup({
  lsp_progress = {
    enable = false,
  },
})

require('mini.indentscope').setup({
  symbol = '│',
  options = {
    try_as_border = true,
  },
})

require('mini.clue').setup({
  triggers = {
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },
    { mode = 'n', keys = '<C-w>' },
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },
  clues = {
    require('mini.clue').gen_clues.builtin_completion(),
    require('mini.clue').gen_clues.g(),
    require('mini.clue').gen_clues.marks(),
    require('mini.clue').gen_clues.registers(),
    require('mini.clue').gen_clues.windows(),
    require('mini.clue').gen_clues.z(),
  },
  window = {
    delay = 300,
    config = {
      width = 'auto',
    },
  },
})

local starter = require('mini.starter')
starter.setup({
  header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
  items = {
    starter.sections.builtin_actions(),
    starter.sections.recent_files(10, true),
    starter.sections.sessions(5, true),
  },
  footer = 'Happy Coding!',
})

require('mini.surround').setup({
  mappings = {
    add = '<leader>sa',
    delete = '<leader>sd',
    find = '<leader>sf',
    find_left = '<leader>sF',
    highlight = '<leader>sh',
    replace = '<leader>sr',
    update_n_lines = '<leader>sn',
  },
  n_lines = 50,
  respect_selection_type = true,
  silent = true,
})

require('mini.jump').setup({
  mappings = {
    forward = 'f',
    backward = 'F',
    forward_till = 't',
    backward_till = 'T',
    repeat_jump = ';',
  },
})

local jump2d = require('mini.jump2d')
jump2d.setup({
  spotter = jump2d.builtin_opts.word_start.spotter,
  view = {
    dim = true,
    n_steps_ahead = 2,
  },
})

local ai = require('mini.ai')
ai.setup({
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter({
      a = { '@block.outer', '@conditional.outer', '@loop.outer' },
      i = { '@block.inner', '@conditional.inner', '@loop.inner' },
    }, {}),
    f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
    c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
    t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>' },
    d = { '%f[%d]%d+' },
    e = {
      '%u[%l%d]+%f[^%l%d]',
      '%f[%S][%l%d]+%f[^%l%d]',
      '%f[%P][%l%d]+%f[^%l%d]',
      '^[%l%d]+%f[^%l%d]',
    },
    u = ai.gen_spec.function_call(),
    U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }),
  },
})

require('mini.move').setup({
  mappings = {
    left = '<M-h>',
    right = '<M-l>',
    down = '<M-S-j>',
    up = '<M-S-k>',
    line_left = '<M-h>',
    line_right = '<M-l>',
    line_down = '<M-S-j>',
    line_up = '<M-S-k>',
  },
})

require('mini.splitjoin').setup({
  mappings = {
    toggle = 'gS',
  },
})

require('mini.operators').setup({
  evaluate = { prefix = 'g=' },
  exchange = { prefix = 'gx' },
  multiply = { prefix = 'gm' },
  replace = { prefix = 'gr' },
  sort = { prefix = 'gs' },
})

vim.keymap.set('n', '<C-j>', 'gJ', { desc = 'Join lines without inserting spaces' })

require('mini.align').setup()

require('mini.comment').setup({
  mappings = {
    comment = 'gc',
    comment_line = 'gcc',
    comment_visual = 'gc',
    textobject = 'gc',
  },
})

local animate = require('mini.animate')
animate.setup({
  cursor = { enable = false },
  scroll = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 80, unit = 'total' }),
    subscroll = animate.gen_subscroll.equal({
      predicate = function(total_scroll) return math.abs(total_scroll) > 5 end,
    }),
  },
  resize = { enable = false },
  open = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 120, unit = 'total' }),
  },
  close = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 120, unit = 'total' }),
  },
})

require('mini.pick').setup({
  mappings = {
    choose_marked = '<C-q>',
    mark = '<C-x>',
    mark_all = '<C-a>',
  },
  options = {
    use_cache = true,
  },
  window = {
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end,
  },
})

require('mini.extra').setup()
require('mini.fuzzy').setup()

require('mini.files').setup({
  mappings = {
    close = 'q',
    go_in = 'l',
    go_in_plus = '<CR>',
    go_out = '',
    go_out_plus = '',
    reset = '<BS>',
    reveal_cwd = '@',
    show_help = 'g?',
    synchronize = '=',
    trim_left = '<',
    trim_right = '>',
  },
  options = {
    use_as_default_explorer = true,
    permanent_delete = true,
  },
  windows = {
    preview = true,
    width_focus = 50,
    width_nofocus = 15,
    width_preview = 40,
  },
})

require('mini.visits').setup({
  store = { autowrite = true },
  track = { event = 'BufEnter', delay = 1000 },
})

require('mini.sessions').setup({
  autowrite = true,
  autoread = true,
  file = 'Session.vim',
  directory = '',
})

require('mini.diff').setup({
  view = {
    style = 'sign',
    signs = {
      add = '│',
      change = '│',
      delete = '_',
    },
  },
})

require('mini.git').setup()

require('mini.completion').setup({
  delay = {
    completion = 100,
    info = 100,
    signature = 50,
  },
  lsp_completion = {
    source_func = 'completefunc',
    auto_setup = true,
  },
  mappings = {
    force_twostep = '<C-Space>',
    force_fallback = '<A-Space>',
  },
  window = {
    info = { border = 'rounded' },
    signature = { border = 'rounded' },
  },
})

require('mini.hipatterns').setup({
  delay = {
    text_change = 200,
    scroll = 50,
  },
  highlighters = {
    fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
    hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
    todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
    note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
    hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
  },
})

require('mini.cursorword').setup()
require('mini.trailspace').setup()
require('mini.bufremove').setup()
require('mini.bracketed').setup()

local map = require('mini.map')
map.setup({
  integrations = {
    map.gen_integration.builtin_search(),
    map.gen_integration.diff(),
    map.gen_integration.diagnostic(),
  },
  symbols = {
    encode = map.gen_encode_symbols.dot('4x2'),
  },
  window = {
    width = 10,
    winblend = 25,
  },
})

require('mini.misc').setup()

require('mini.snippets').setup({
  snippets = {
    require('mini.snippets').gen_loader.from_lang(),
  },
})

vim.keymap.set('i', '<C-j>', '<Down>', { desc = 'Move cursor down in insert mode' })
vim.keymap.set('i', '<C-k>', '<Up>', { desc = 'Move cursor up in insert mode' })
