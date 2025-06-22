local env = require("tangerine.utils.env")
local win = {}
local win_stack = {total = 0}
win.__stack = win_stack
local function insert_stack(win_2a)
  _G.assert((nil ~= win_2a), "Missing argument win* on tangerine/utils/window.fnl:19")
  return table.insert(win_stack, {win_2a, vim.api.nvim_win_get_config(win_2a)})
end
local function remove_stack(idx_2a, conf_2a)
  _G.assert((nil ~= conf_2a), "Missing argument conf* on tangerine/utils/window.fnl:23")
  _G.assert((nil ~= idx_2a), "Missing argument idx* on tangerine/utils/window.fnl:23")
  for idx, _1_ in ipairs(win_stack) do
    local win0 = _1_[1]
    local conf = _1_[2]
    if ((idx_2a < idx) and vim.api.nvim_win_is_valid(win0)) then
      conf["row"][false] = (conf.row[false] + conf_2a.height + 2)
      vim.api.nvim_win_set_config(win0, conf)
    else
    end
  end
  return table.remove(win_stack, idx_2a)
end
local function normalize_parent(win_2a)
  _G.assert((nil ~= win_2a), "Missing argument win* on tangerine/utils/window.fnl:31")
  for idx, _3_ in ipairs(win_stack) do
    local win0 = _3_[1]
    local conf = _3_[2]
    if (win0 == win_2a) then
      vim.api.nvim_set_current_win(conf.win)
    else
    end
  end
  return nil
end
local function update_stack()
  local total = 0
  for idx, _5_ in ipairs(win_stack) do
    local win0 = _5_[1]
    local conf = _5_[2]
    if vim.api.nvim_win_is_valid(win0) then
      total = (total + conf.height + 2)
    elseif "else" then
      remove_stack(idx, conf)
    else
    end
  end
  win_stack["total"] = total
  return true
end
do
  local timer = vim.loop.new_timer()
  timer:start(200, 200, vim.schedule_wrap(update_stack))
end
local function move_stack(start, steps)
  _G.assert((nil ~= steps), "Missing argument steps on tangerine/utils/window.fnl:57")
  _G.assert((nil ~= start), "Missing argument start on tangerine/utils/window.fnl:57")
  local index = start
  for idx, _7_ in ipairs(win_stack) do
    local win0 = _7_[1]
    local conf = _7_[2]
    local idx_2a = (idx + steps)
    if ((win0 == vim.api.nvim_get_current_win()) and win_stack[idx_2a]) then
      index = idx_2a
    else
    end
  end
  if win_stack[index] then
    return vim.api.nvim_set_current_win(win_stack[index][1])
  else
    return nil
  end
end
win.next = function(_3fsteps)
  return move_stack(1, (_3fsteps or 1))
end
win.prev = function(_3fsteps)
  return move_stack(#win_stack, (-1 * (_3fsteps or 1)))
end
win.resize = function(n)
  _G.assert((nil ~= n), "Missing argument n on tangerine/utils/window.fnl:75")
  local n0 = n
  local idx_2a = (#win_stack + 1)
  for idx, _10_ in ipairs(win_stack) do
    local win0 = _10_[1]
    local conf = _10_[2]
    if (win0 == vim.api.nvim_get_current_win()) then
      if (0 >= (conf.height + n0)) then
        n0 = (1 - conf.height)
      else
      end
      idx_2a = idx
      conf["height"] = (conf.height + n0)
    else
    end
    if (idx_2a <= idx) then
      conf["row"][false] = (conf.row[false] - n0)
      vim.api.nvim_win_set_config(win0, conf)
    else
    end
  end
  return true
end
win.close = function()
  local current = vim.api.nvim_get_current_win()
  for idx, _14_ in ipairs(win_stack) do
    local win0 = _14_[1]
    local conf = _14_[2]
    if (win0 == current) then
      vim.api.nvim_win_close(win0, true)
      update_stack()
      local _15_
      if win_stack[idx] then
        _15_ = idx
      elseif win_stack[(idx + 1)] then
        _15_ = (idx + 1)
      else
        _15_ = (idx - 1)
      end
      local function _17_()
        return 0
      end
      move_stack(_15_, _17_())
    else
    end
  end
  return true
end
win.killall = function()
  for idx = 1, #win_stack do
    vim.api.nvim_win_close(win_stack[idx][1], true)
    win_stack[idx] = nil
  end
  win_stack["total"] = 0
  return true
end
local function lineheight(lines)
  _G.assert((nil ~= lines), "Missing argument lines on tangerine/utils/window.fnl:116")
  local height = 0
  local width = vim.api.nvim_win_get_width(0)
  for _, line in ipairs(lines) do
    height = (math.max(math.ceil(((#line + 2) / width)), 1) + height)
  end
  return height
end
local function nmap_21(buffer, ...)
  _G.assert((nil ~= buffer), "Missing argument buffer on tangerine/utils/window.fnl:128")
  for _, _19_ in ipairs({...}) do
    local lhs = _19_[1]
    local rhs = _19_[2]
    vim.api.nvim_buf_set_keymap(buffer, "n", lhs, ("<cmd>" .. rhs .. "<CR>"), {silent = true, noremap = true})
  end
  return nil
end
local function setup_mappings(buffer)
  _G.assert((nil ~= buffer), "Missing argument buffer on tangerine/utils/window.fnl:133")
  local w = env.get("keymaps", "float")
  return nmap_21(buffer, {w.next, "FnlWinNext"}, {w.prev, "FnlWinPrev"}, {w.kill, "FnlWinKill"}, {w.close, "FnlWinClose"}, {w.resizef, "FnlWinResize 1"}, {w.resizeb, "FnlWinResize -1"})
end
win["create-float"] = function(lineheight0, filetype, hl_normal, _3fhl_border)
  _G.assert((nil ~= hl_normal), "Missing argument hl-normal on tangerine/utils/window.fnl:148")
  _G.assert((nil ~= filetype), "Missing argument filetype on tangerine/utils/window.fnl:148")
  _G.assert((nil ~= lineheight0), "Missing argument lineheight on tangerine/utils/window.fnl:148")
  normalize_parent(vim.api.nvim_get_current_win())
  local buffer = vim.api.nvim_create_buf(false, true)
  local win_height = vim.api.nvim_win_get_height(0)
  local bordersize = 2
  local height = math.max(1, math.floor(math.min((win_height / 1.5), lineheight0)))
  vim.api.nvim_open_win(buffer, true, {row = (win_height - bordersize - height - win_stack.total), col = 0, height = height, width = 360, style = "minimal", anchor = "NW", border = "single", relative = "win"})
  insert_stack(vim.api.nvim_get_current_win())
  update_stack()
  vim.api.nvim_buf_set_option(buffer, "ft", filetype)
  vim.api.nvim_win_set_option(0, "winhl", ("Normal:" .. hl_normal .. ",FloatBorder:" .. (_3fhl_border or hl_normal)))
  setup_mappings(buffer)
  return buffer
end
win["set-float"] = function(lines, filetype, hl_normal, _3fhl_border)
  _G.assert((nil ~= hl_normal), "Missing argument hl-normal on tangerine/utils/window.fnl:175")
  _G.assert((nil ~= filetype), "Missing argument filetype on tangerine/utils/window.fnl:175")
  _G.assert((nil ~= lines), "Missing argument lines on tangerine/utils/window.fnl:175")
  local lines0 = vim.split(lines, "\n")
  local nlines = lineheight(lines0)
  local buffer = win["create-float"](nlines, filetype, hl_normal, _3fhl_border)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines0)
  return true
end
return win