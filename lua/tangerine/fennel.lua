local env = require("tangerine.utils.env")
local fennel = {}
local function format_path(path, ext, macro_3f)
  _G.assert((nil ~= macro_3f), "Missing argument macro? on tangerine/fennel.fnl:14")
  _G.assert((nil ~= ext), "Missing argument ext on tangerine/fennel.fnl:14")
  _G.assert((nil ~= path), "Missing argument path on tangerine/fennel.fnl:14")
  local _1_
  if macro_3f then
    _1_ = "init-macros."
  else
    _1_ = "init."
  end
  return (path .. "?." .. ext .. ";" .. path .. "?/" .. _1_ .. ext)
end
local function get_path(ext, macro_path_3f)
  _G.assert((nil ~= macro_path_3f), "Missing argument macro-path? on tangerine/fennel.fnl:19")
  _G.assert((nil ~= ext), "Missing argument ext on tangerine/fennel.fnl:19")
  local out = {}
  local source = env.get("source")
  local custom = env.get("custom")
  local rtps = (vim.o.runtimepath .. ",")
  table.insert(out, format_path("./", ext, macro_path_3f))
  table.insert(out, format_path(source, ext, macro_path_3f))
  for _, _3_ in ipairs(custom) do
    local s = _3_[1]
    local t = _3_[2]
    table.insert(out, format_path(s, ext, macro_path_3f))
    table.insert(out, format_path(t, ext, macro_path_3f))
  end
  for entry in rtps:gmatch("(.-),") do
    local glob = vim.fn.glob((entry .. "/fnl/"), 0, 1)
    for _, path in ipairs(glob) do
      table.insert(out, format_path(path, ext, macro_path_3f))
    end
  end
  return table.concat(out, ";")
end
local original_path = package.path
fennel.load = function(_3fversion)
  local version = (_3fversion or env.get("compiler", "version"))
  local fennel0 = require(("tangerine.fennel." .. version))
  fennel0.path = get_path("fnl", false)
  fennel0["macro-path"] = get_path("fnl", true)
  return env.get("compiler", "adviser")(fennel0)
end
fennel["patch-path"] = function()
  local target = get_path("lua", false)
  local source = format_path(env.get("target"), "lua", false)
  package.path = (original_path .. ";" .. target .. ";" .. source)
  return package.path
end
return fennel