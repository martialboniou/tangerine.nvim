local df = {}
df["create-marker"] = function(source)
  _G.assert((nil ~= source), "Missing argument source on tangerine/utils/diff.fnl:11")
  local base = "-- :fennel:"
  local meta = vim.fn.getftime(source)
  return (base .. meta)
end
df["read-marker"] = function(path)
  _G.assert((nil ~= path), "Missing argument path on tangerine/utils/diff.fnl:17")
  local file = assert(io.open(path, "r"))
  local function close_handlers_12_auto(ok_13_auto, ...)
    file:close()
    if ok_13_auto then
      return ...
    else
      return error(..., 0)
    end
  end
  local function _2_()
    local bytes = (file:read(21) or "")
    local marker = bytes:match(":fennel:([0-9]+)")
    if marker then
      return tonumber(marker)
    elseif "else" then
      return false
    else
      return nil
    end
  end
  return close_handlers_12_auto(_G.xpcall(_2_, (package.loaded.fennel or _G.debug or {}).traceback))
end
df["stale?"] = function(source, target)
  _G.assert((nil ~= target), "Missing argument target on tangerine/utils/diff.fnl:26")
  _G.assert((nil ~= source), "Missing argument source on tangerine/utils/diff.fnl:26")
  if (1 ~= vim.fn.filereadable(target)) then
    return true
  else
  end
  local source_time = vim.fn.getftime(source)
  local marker_time = df["read-marker"](target)
  return (source_time ~= marker_time)
end
return df