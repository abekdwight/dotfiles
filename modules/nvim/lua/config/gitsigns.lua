local gitsigns = require('gitsigns')

gitsigns.setup({
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '▎' },
    topdelete = { text = '▎' },
    changedelete = { text = '▎' },
    untracked = { text = '▎' },
  },
  signs_staged = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '▎' },
    topdelete = { text = '▎' },
    changedelete = { text = '▎' },
    untracked = { text = '▎' },
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- hunk navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = '次のHunk' })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = '前のHunk' })

    -- hunk actions
    map('n', '<leader>gs', gs.stage_hunk, { desc = 'HunkをStage' })
    map('n', '<leader>gr', gs.reset_hunk, { desc = 'HunkをReset' })
    map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = '選択範囲をStage' })
    map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = '選択範囲をReset' })
    map('n', '<leader>gS', gs.stage_buffer, { desc = 'バッファ全体をStage' })
    map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Stageを取り消し' })
    map('n', '<leader>gR', gs.reset_buffer, { desc = 'バッファ全体をReset' })

    -- preview / diff
    map('n', '<leader>gp', gs.preview_hunk, { desc = 'Hunkをプレビュー' })
    map('n', '<leader>gb', gs.blame_line, { desc = '行のBlame' })

    -- text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Hunk選択' })
  end,
})
