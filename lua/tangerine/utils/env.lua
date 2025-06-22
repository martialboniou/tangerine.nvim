local config_dir = vim.fn.stdpath("config")
local function endswith(str, args)
  _G.assert((nil ~= args), "Missing argument args on tangerine/utils/env.fnl:11")
  _G.assert((nil ~= str), "Missing argument str on tangerine/utils/env.fnl:11")
  for i, v in pairs(args) do
    if vim.endswith(str, v) then
      return true
    else
    end
  end
  return nil
end
local function resolve(path)
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/env.fnl:17")
  local out = vim.fn.resolve(vim.fn.expand(path))
  if endswith(out, {"/", ".fnl", ".lua"}) then
    return out
  else
    return (out .. "/")
  end
end
local function rtpdirs(dirs)
  _G.assert((nil ~= dirs), "Missing argument dirs on tangerine/utils/env.fnl:25")
  local tbl_21_auto = {}
  local i_22_auto = 0
  for _, dir in ipairs(dirs) do
    local val_23_auto
    do
      local path = resolve(dir)
      if vim.startswith(path, "/") then
        val_23_auto = path
      else
        val_23_auto = (config_dir .. "/" .. path)
      end
    end
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
local function get_type(x)
  _G.assert((nil ~= x), "Missing argument x on tangerine/utils/env.fnl:34")
  if vim.islist(x) then
    return "list"
  else
    return type(x)
  end
end
local function table_3f(tbl, scm)
  _G.assert((nil ~= scm), "Missing argument scm on tangerine/utils/env.fnl:41")
  _G.assert((nil ~= tbl), "Missing argument tbl on tangerine/utils/env.fnl:41")
  return (("table" == type(tbl)) and not vim.islist(scm))
end
local function deepcopy(tbl1, tbl2)
  _G.assert((nil ~= tbl2), "Missing argument tbl2 on tangerine/utils/env.fnl:45")
  _G.assert((nil ~= tbl1), "Missing argument tbl1 on tangerine/utils/env.fnl:45")
  for key, val in pairs(tbl1) do
    if table_3f(val, tbl2[key]) then
      deepcopy(val, tbl2[key])
    elseif "else" then
      tbl2[key] = val
    else
    end
  end
  return nil
end
local function luafmt()
  local exec = vim.fn.expand("~/.luarocks/bin/lua-format")
  local width = vim.api.nvim_win_get_width(0)
  return {exec, "--spaces-inside-table-braces", "--column-table-limit", math.floor((width / 1.7)), "--column-limit", width}
end
local pre_schema
local function _7_(_241)
  local tbl_21_auto = {}
  local i_22_auto = 0
  for _, _8_ in ipairs(_241) do
    local s = _8_[1]
    local t = _8_[2]
    local val_23_auto = {resolve(s), resolve(t)}
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
pre_schema = {source = resolve, target = resolve, vimrc = resolve, rtpdirs = rtpdirs, custom = _7_, compiler = nil, eval = nil, keymaps = nil, highlight = nil}
local schema = {source = "string", target = "string", vimrc = "string", rtpdirs = {"string"}, custom = {{"string"}}, compiler = {float = "boolean", clean = "boolean", force = "boolean", verbose = "boolean", version = {"oneof", {"latest", "1-5-1", "1-5-0", "1-4-2", "1-4-1", "1-4-0", "1-3-1", "1-3-0", "1-2-1", "1-2-0", "1-1-0", "1-0-0"}}, adviser = "function", globals = {"string"}, hooks = {"array", {"onsave", "onload", "oninit"}}}, eval = {float = "boolean", luafmt = "function", diagnostic = {virtual = "boolean", timeout = "number"}}, keymaps = {peek_buffer = "string", eval_buffer = "string", goto_output = "string", float = {next = "string", prev = "string", kill = "string", close = "string", resizef = "string", resizeb = "string"}}, highlight = {float = "string", success = "string", errors = "string"}}
local ENV
local function _10_(_241)
  return _241
end
ENV = {vimrc = resolve((config_dir .. "/init.fnl")), source = resolve((config_dir .. "/fnl/")), target = resolve((config_dir .. "/lua/")), rtpdirs = {}, custom = {}, compiler = {float = true, clean = true, verbose = true, version = "latest", adviser = _10_, globals = vim.tbl_keys(_G), hooks = {}, force = false}, eval = {float = true, luafmt = luafmt, diagnostic = {virtual = true, timeout = 10}}, keymaps = {eval_buffer = "gE", peek_buffer = "gL", goto_output = "gO", float = {next = "<C-K>", prev = "<C-J>", kill = "<Esc>", close = "<Enter>", resizef = "<C-W>=", resizeb = "<C-W>-"}}, highlight = {float = "Normal", success = "String", errors = "DiagnosticError"}}
local function validate_err(key, msg, ...)
  _G.assert((nil ~= msg), "Missing argument msg on tangerine/utils/env.fnl:151")
  _G.assert((nil ~= key), "Missing argument key on tangerine/utils/env.fnl:151")
  return error(("[tangerine]: bad argument to 'setup()' in key " .. key .. ": " .. table.concat({msg, ...}, " ") .. "."))
end
local function validate_type(key, val, scm)
  _G.assert((nil ~= scm), "Missing argument scm on tangerine/utils/env.fnl:156")
  _G.assert((nil ~= val), "Missing argument val on tangerine/utils/env.fnl:156")
  _G.assert((nil ~= key), "Missing argument key on tangerine/utils/env.fnl:156")
  local tv = get_type(val)
  if (scm ~= tv) then
    return validate_err(key, scm, "expected got", tv)
  else
    return nil
  end
end
local function validate_oneof(key, val, scm)
  _G.assert((nil ~= scm), "Missing argument scm on tangerine/utils/env.fnl:162")
  _G.assert((nil ~= val), "Missing argument val on tangerine/utils/env.fnl:162")
  _G.assert((nil ~= key), "Missing argument key on tangerine/utils/env.fnl:162")
  if not vim.tbl_contains(scm, val) then
    return validate_err(key, "value expected to be one of", vim.inspect(scm), "got", vim.inspect(val))
  else
    return nil
  end
end
local function validate_array(key, array, scm)
  _G.assert((nil ~= scm), "Missing argument scm on tangerine/utils/env.fnl:168")
  _G.assert((nil ~= array), "Missing argument array on tangerine/utils/env.fnl:168")
  _G.assert((nil ~= key), "Missing argument key on tangerine/utils/env.fnl:168")
  validate_type(key, array, "list")
  for _, val in ipairs(array) do
    validate_oneof(key, val, scm)
  end
  return nil
end
local function validate_list(key, list, scm)
  _G.assert((nil ~= scm), "Missing argument scm on tangerine/utils/env.fnl:174")
  _G.assert((nil ~= list), "Missing argument list on tangerine/utils/env.fnl:174")
  _G.assert((nil ~= key), "Missing argument key on tangerine/utils/env.fnl:174")
  validate_type(key, list, "list")
  for _, val in ipairs(list) do
    if ("list" == get_type(scm)) then
      validate_list(key, val, scm[1])
    else
      local tv = get_type(val)
      if (scm ~= tv) then
        validate_err(key, "member", (vim.inspect(val) .. ":"), scm, "expected got", tv)
      else
      end
    end
  end
  return nil
end
local function validate(tbl, schema0)
  _G.assert((nil ~= schema0), "Missing argument schema on tangerine/utils/env.fnl:185")
  _G.assert((nil ~= tbl), "Missing argument tbl on tangerine/utils/env.fnl:185")
  for key, val in pairs(tbl) do
    local scm = schema0[key]
    if not scm then
      validate_err(key, "invalid", "key")
    else
    end
    local _16_, _17_ = get_type(scm), scm[1]
    if ((_16_ == "string") and (_17_ == nil)) then
      validate_type(key, val, scm)
    elseif ((_16_ == "table") and (_17_ == nil)) then
      validate(val, scm)
    elseif ((_16_ == "list") and (_17_ == "oneof")) then
      validate_oneof(key, val, scm[2])
    elseif ((_16_ == "list") and (_17_ == "array")) then
      validate_array(key, val, scm[2])
    elseif ((_16_ == "list") and true) then
      local _ = _17_
      validate_list(key, val, scm[1])
    else
    end
  end
  return nil
end
local function pre_process(tbl, schema0)
  _G.assert((nil ~= schema0), "Missing argument schema on tangerine/utils/env.fnl:198")
  _G.assert((nil ~= tbl), "Missing argument tbl on tangerine/utils/env.fnl:198")
  for key, val in pairs(tbl) do
    local pre = schema0[key]
    local _19_ = type(pre)
    if (_19_ == "table") then
      pre_process(val, pre)
    elseif (_19_ == "function") then
      tbl[key] = pre(val)
    else
    end
  end
  return tbl
end
local function env_get(...)
  local keys = {...}
  local cur = ENV
  while ((nil ~= cur) and (0 < #keys)) do
    cur = cur[table.remove(keys, 1)]
  end
  return cur
end
local function env_get_conf(opts, keys)
  _G.assert((nil ~= keys), "Missing argument keys on tangerine/utils/env.fnl:220")
  _G.assert((nil ~= opts), "Missing argument opts on tangerine/utils/env.fnl:220")
  local last = keys[#keys]
  if (nil ~= opts[last]) then
    return pre_process(opts, pre_schema)[last]
  else
    return env_get(unpack(keys))
  end
end
local function env_set(tbl)
  _G.assert((nil ~= tbl), "Missing argument tbl on tangerine/utils/env.fnl:230")
  validate(tbl, schema)
  return deepcopy(pre_process(tbl, pre_schema), ENV)
end
return {get = env_get, set = env_set, conf = env_get_conf}