local M = {}

function M.format_owners(owners, cfg)
  local text
  local mode = cfg.display_mode
  if mode == "first" then
    text = owners[1]
  elseif mode == "first_plus_count" then
    text = owners[1]
    if #owners > 1 then
      text = text .. " (+" .. (#owners - 1) .. ")"
    end
  else -- "all"
    text = table.concat(owners, cfg.separator)
  end

  if cfg.max_length and cfg.max_length > 0 then
    if vim.fn.strdisplaywidth(text) > cfg.max_length then
      local suffix = cfg.truncation_suffix or ""
      local suffix_w = vim.fn.strdisplaywidth(suffix)
      local target = cfg.max_length - suffix_w
      -- Trim by characters until display width fits
      while vim.fn.strdisplaywidth(text) > target and #text > 0 do
        text = text:sub(1, -2)
      end
      text = text .. suffix
    end
  end

  return text
end

function M.with_icon(text, cfg)
  if cfg.icon and cfg.icon ~= "" then
    return cfg.icon .. cfg.icon_separator .. text
  end
  return text
end

function M.display(owners, cfg)
  if owners and #owners > 0 then
    return M.with_icon(M.format_owners(owners, cfg), cfg)
  end
  if cfg.show_placeholder_when_empty then
    return M.with_icon(cfg.placeholder, cfg)
  end
  return ""
end

return M
