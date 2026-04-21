local format = require("lualine-codeowners.format")
local defaults = require("lualine-codeowners.config").defaults

local function cfg(overrides)
  return vim.tbl_deep_extend("force", defaults, overrides or {})
end

describe("format_owners", function()
  it("display_mode=all joins with separator", function()
    local result = format.format_owners({ "@A", "@B" }, cfg({ display_mode = "all", separator = ", " }))
    assert.equals("@A, @B", result)
  end)

  it("display_mode=first_plus_count with 3 owners", function()
    local result = format.format_owners({ "@A", "@B", "@C" }, cfg({ display_mode = "first_plus_count" }))
    assert.equals("@A (+2)", result)
  end)

  it("display_mode=first with 3 owners returns only first", function()
    local result = format.format_owners({ "@A", "@B", "@C" }, cfg({ display_mode = "first" }))
    assert.equals("@A", result)
  end)

  it("truncates long text and appends suffix", function()
    local long = "@very-long-team-name-that-exceeds-limit"
    local result = format.format_owners(
      { long },
      cfg({ display_mode = "first", max_length = 10, truncation_suffix = "…" })
    )
    assert.is_true(vim.fn.strdisplaywidth(result) <= 10)
    assert.is_true(result:sub(-3) == "\xe2\x80\xa6") -- UTF-8 bytes for "…"
  end)
end)

describe("with_icon", function()
  it("prepends icon and separator when icon is set", function()
    local result = format.with_icon("text", cfg({ icon = "", icon_separator = "  " }))
    assert.equals("  text", result)
  end)

  it("returns bare text when icon is empty string", function()
    local result = format.with_icon("text", cfg({ icon = "" }))
    assert.equals("text", result)
  end)
end)

describe("display", function()
  it("with owners returns icon + formatted", function()
    local result = format.display({ "@A" }, cfg({ icon = "", icon_separator = "  ", display_mode = "first" }))
    assert.equals("  @A", result)
  end)

  it("nil owners with show_placeholder_when_empty=true returns placeholder", function()
    local result = format.display(nil, cfg({ icon = "", icon_separator = "  ", placeholder = "no owner" }))
    assert.equals("  no owner", result)
  end)

  it("nil owners with show_placeholder_when_empty=false returns empty string", function()
    local result = format.display(nil, cfg({ show_placeholder_when_empty = false }))
    assert.equals("", result)
  end)
end)
