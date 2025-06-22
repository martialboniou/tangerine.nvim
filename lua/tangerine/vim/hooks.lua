local env = require("tangerine.utils.env")
local hooks = {}
local windows_3f = (_G.jit.os == "Windows")
local function esc_file_pattern(path)
  _G.assert((nil ~= path), "Missing argument path on tangerine/vim/hooks.fnl:16")
  return (path:gsub("[%*%?%[%]%{%}\\,]", "\\%1"))
end
local function resolve_file_pattern(path)
  _G.assert((nil ~= path), "Missing argument path on tangerine/vim/hooks.fnl:21")
  local function _1_()
    if windows_3f then
      return path:gsub("\\", "/")
    else
      return path
    end
  end
  return esc_file_pattern(_1_())
end
local function exec(...)
  return vim.cmd(table.concat({...}, " "))
end
local function parse_autocmd(opts)
  _G.assert((nil ~= opts), "Missing argument opts on tangerine/vim/hooks.fnl:30")
  local groups = table.concat(table.remove(opts, 1), " ")
  return "au", groups, table.concat(opts, " ")
end
local function augroup(name, ...)
  _G.assert((nil ~= name), "Missing argument name on tangerine/vim/hooks.fnl:35")
  exec("augroup", name)
  exec("au!")
  for idx, val in ipairs({...}) do
    exec(parse_autocmd(val))
  end
  exec("augroup", "END")
  return true
end
local map = vim.tbl_map
hooks.run = function()
  if env.get("compiler", "clean") then
    _G.tangerine.api.clean.orphaned()
  else
  end
  return _G.tangerine.api.compile.all()
end
local run_hooks = "lua require 'tangerine.vim.hooks'.run()"
hooks.onsave = function()
  local patterns
  local function _3_(_241)
    return (resolve_file_pattern(_241) .. "*.fnl")
  end
  local function _4_(_241)
    return (resolve_file_pattern(_241) .. "*.fnl")
  end
  local function _5_()
    local tbl_21_auto = {}
    local i_22_auto = 0
    for _, _6_ in ipairs(env.get("custom")) do
      local s = _6_[1]
      local val_23_auto = s
      if (nil ~= val_23_auto) then
        i_22_auto = (i_22_auto + 1)
        tbl_21_auto[i_22_auto] = val_23_auto
      else
      end
    end
    return tbl_21_auto
  end
  patterns = vim.tbl_flatten({resolve_file_pattern(env.get("vimrc")), (resolve_file_pattern(env.get("source")) .. "*.fnl"), map(_3_, env.get("rtpdirs")), map(_4_, _5_())})
  return augroup("tangerine-onsave", {{"BufWritePost", table.concat(patterns, ",")}, run_hooks})
end
hooks.onload = function()
  return augroup("tangerine-onload", {{"VimEnter", "*"}, run_hooks})
end
hooks.oninit = function()
  return hooks.run()
end
return hooks