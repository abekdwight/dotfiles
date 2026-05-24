-- mini.files Git status integration
-- Based on: https://gist.github.com/bassamsdata/eec0a3065152226581f8d4244cce9051

local nsMiniFiles = vim.api.nvim_create_namespace('mini_files_git')
local autocmd = vim.api.nvim_create_autocmd
local uv = vim.uv or vim.loop

local _, MiniFiles = pcall(require, 'mini.files')
if not MiniFiles then
  return
end

-- Cache for git status
local gitStatusCache = {}
local cacheTimeout = 2000 -- milliseconds

---@param status string
---@param is_symlink boolean
---@return string symbol, string hlGroup
local function mapSymbols(status, is_symlink)
  local statusMap = {
    -- stylua: ignore start
    [' M'] = { symbol = 'M', hlGroup = 'MiniDiffSignChange' }, -- Modified in working tree
    ['M '] = { symbol = '✹', hlGroup = 'MiniDiffSignChange' }, -- Modified in index
    ['MM'] = { symbol = '≠', hlGroup = 'MiniDiffSignChange' }, -- Modified in both
    ['A '] = { symbol = 'A', hlGroup = 'MiniDiffSignAdd'    }, -- Added to staging
    ['AA'] = { symbol = '≈', hlGroup = 'MiniDiffSignAdd'    }, -- Added in both
    ['D '] = { symbol = 'D', hlGroup = 'MiniDiffSignDelete' }, -- Deleted from staging
    ['AM'] = { symbol = '⊕', hlGroup = 'MiniDiffSignChange' }, -- Added in tree, modified in index
    ['AD'] = { symbol = '-•', hlGroup = 'MiniDiffSignChange' }, -- Added in index, deleted in tree
    ['R '] = { symbol = '→', hlGroup = 'MiniDiffSignChange' }, -- Renamed in index
    ['U '] = { symbol = '‖', hlGroup = 'MiniDiffSignChange' }, -- Unmerged path
    ['UU'] = { symbol = '⇄', hlGroup = 'MiniDiffSignAdd'    }, -- Unmerged
    ['UA'] = { symbol = '⊕', hlGroup = 'MiniDiffSignAdd'    }, -- Unmerged, added in tree
    ['??'] = { symbol = '?', hlGroup = 'MiniDiffSignDelete' }, -- Untracked
    ['!!'] = { symbol = '!', hlGroup = 'MiniDiffSignChange' }, -- Ignored
    -- stylua: ignore end
  }

  local result = statusMap[status] or { symbol = '?', hlGroup = 'NonText' }
  local gitSymbol = result.symbol
  local gitHlGroup = result.hlGroup

  local symlinkSymbol = is_symlink and '↩' or ''

  local combinedSymbol = (symlinkSymbol .. gitSymbol)
    :gsub('^%s+', '')
    :gsub('%s+$', '')
  local combinedHlGroup = is_symlink and 'MiniDiffSignDelete' or gitHlGroup

  return combinedSymbol, combinedHlGroup
end

---@param path string
---@return boolean
local function isSymlink(path)
  local stat = uv.fs_lstat(path)
  return stat and stat.type == 'link'
end

---@param cwd string
---@param callback function
local function fetchGitStatus(cwd, callback)
  local clean_cwd = cwd:gsub('^minifiles://%d+/', '')
  vim.system(
    { 'git', 'status', '--ignored', '--porcelain' },
    { text = true, cwd = clean_cwd },
    function(content)
      if content.code == 0 then
        callback(content.stdout)
      end
    end
  )
end

---@param content string
---@return table
local function parseGitStatus(content)
  local gitStatusMap = {}
  for line in content:gmatch('[^\r\n]+') do
    local status, filePath = string.match(line, '^(..)%s+(.*)')
    if not status or not filePath then
      goto continue
    end

    local parts = {}
    for part in filePath:gmatch('[^/]+') do
      table.insert(parts, part)
    end

    local currentKey = ''
    for i, part in ipairs(parts) do
      if i > 1 then
        currentKey = currentKey .. '/' .. part
      else
        currentKey = part
      end

      if i == #parts then
        gitStatusMap[currentKey] = status
      elseif not gitStatusMap[currentKey] and status ~= '!!' then
        gitStatusMap[currentKey] = status
      end
    end

    ::continue::
  end
  return gitStatusMap
end

---@param buf_id integer
---@param gitStatusMap table
local function updateMiniWithGit(buf_id, gitStatusMap)
  vim.schedule(function()
    local nlines = vim.api.nvim_buf_line_count(buf_id)
    local cwd = vim.fs.root(buf_id, '.git')
    if not cwd then
      return
    end
    local escapedcwd = vim.fs.normalize(vim.pesc(cwd))

    for i = 1, nlines do
      local entry = MiniFiles.get_fs_entry(buf_id, i)
      if not entry then
        break
      end
      local relativePath = entry.path:gsub('^' .. escapedcwd .. '/', '')
      local status = gitStatusMap[relativePath]

      if status then
        local symbol, hlGroup = mapSymbols(status, isSymlink(entry.path))
        vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
          sign_text = symbol,
          sign_hl_group = hlGroup,
          priority = 2,
        })
      end
    end
  end)
end

---@param buf_id integer
local function updateGitStatus(buf_id)
  local root = vim.fs.root(buf_id, '.git')
  if not root then
    return
  end

  local cwd = root
  local currentTime = os.time()

  if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
    updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
  else
    fetchGitStatus(cwd, function(content)
      local gitStatusMap = parseGitStatus(content)
      gitStatusCache[cwd] = {
        time = currentTime,
        statusMap = gitStatusMap,
      }
      updateMiniWithGit(buf_id, gitStatusMap)
    end)
  end
end

local function clearCache()
  gitStatusCache = {}
end

local function augroup(name)
  return vim.api.nvim_create_augroup('MiniFilesGit_' .. name, { clear = true })
end

autocmd('User', {
  group = augroup('open'),
  pattern = 'MiniFilesExplorerOpen',
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    updateGitStatus(bufnr)
  end,
})

autocmd('User', {
  group = augroup('close'),
  pattern = 'MiniFilesExplorerClose',
  callback = function()
    clearCache()
  end,
})

autocmd('User', {
  group = augroup('update'),
  pattern = 'MiniFilesBufferUpdate',
  callback = function(args)
    local bufnr = args.data.buf_id
    local cwd = vim.fs.root(bufnr, '.git')
    if cwd and gitStatusCache[cwd] then
      updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
    end
  end,
})
