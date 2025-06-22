local env = require("tangerine.utils.env")
local p = {}
local windows_3f = (_G.jit.os == "Windows")
p.match = function(path, pattern)
  _G.assert((nil ~= pattern), "Missing argument pattern on tangerine/utils/path.fnl:14")
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/path.fnl:14")
  if windows_3f then
    return path:match(pattern:gsub("/", "[\\/]"))
  else
    return path:match(pattern)
  end
end
p.gsub = function(path, pattern, repl)
  _G.assert((nil ~= repl), "Missing argument repl on tangerine/utils/path.fnl:20")
  _G.assert((nil ~= pattern), "Missing argument pattern on tangerine/utils/path.fnl:20")
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/path.fnl:20")
  if windows_3f then
    return path:gsub(pattern:gsub("/", "[\\/]"), repl)
  else
    return path:gsub(pattern, repl)
  end
end
p.shortname = function(path)
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/path.fnl:26")
  return (p.match(path, ".+/fnl/(.+)") or p.match(path, ".+/lua/(.+)") or p.match(path, ".+/(.+/.+)"))
end
p.resolve = function(path)
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/path.fnl:32")
  return vim.fn.resolve(vim.fn.expand(path))
end
local vimrc_out = (env.get("target") .. "tangerine_vimrc.lua")
local function esc_regex(str)
  _G.assert((nil ~= str), "Missing argument str on tangerine/utils/path.fnl:42")
  return str:gsub("[%%%^%$%(%)%[%]%{%}%.%*%+%-%?]", "%%%1")
end
p["transform-path"] = function(path, _3_, _4_)
  local key1 = _3_[1]
  local ext1 = _3_[2]
  local key2 = _4_[1]
  local ext2 = _4_[2]
  _G.assert((nil ~= ext2), "Missing argument ext2 on tangerine/utils/path.fnl:46")
  _G.assert((nil ~= key2), "Missing argument key2 on tangerine/utils/path.fnl:46")
  _G.assert((nil ~= ext1), "Missing argument ext1 on tangerine/utils/path.fnl:46")
  _G.assert((nil ~= key1), "Missing argument key1 on tangerine/utils/path.fnl:46")
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/path.fnl:46")
  local from = ("^" .. esc_regex(env.get(key1)))
  local to = esc_regex(env.get(key2))
  local path0 = path:gsub(("%." .. ext1 .. "$"), ("." .. ext2))
  if path0:find(from) then
    return path0:gsub(from, to)
  else
    return p.gsub(path0, ("/" .. ext1 .. "/"), ("/" .. ext2 .. "/"))
  end
end
p.target = function(path)
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/path.fnl:55")
  local vimrc = env.get("vimrc")
  if (path == vimrc) then
    return vimrc_out
  else
    return p["transform-path"](path, {"source", "fnl"}, {"target", "lua"})
  end
end
p.source = function(path)
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/path.fnl:62")
  local vimrc = env.get("vimrc")
  if (path == vimrc_out) then
    return vimrc
  else
    return p["transform-path"](path, {"target", "lua"}, {"source", "fnl"})
  end
end
p["goto-output"] = function()
  local source = vim.fn.expand("%:p")
  local target = p.target(source)
  if ((1 == vim.fn.filereadable(target)) and (source ~= target)) then
    return vim.cmd(("edit" .. target))
  elseif "else" then
    return print("[tangerine]: error in goto-output, target not readable.")
  else
    return nil
  end
end
p.wildcard = function(dir, pat)
  _G.assert((nil ~= pat), "Missing argument pat on tangerine/utils/path.fnl:87")
  _G.assert((nil ~= dir), "Missing argument dir on tangerine/utils/path.fnl:87")
  return vim.fn.glob((dir .. pat), 0, 1)
end
return p