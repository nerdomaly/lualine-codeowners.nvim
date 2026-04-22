local config = require("lualine-codeowners.config")

describe("config.set locations validation", function()
  after_each(function()
    config.set({}) -- reset to defaults
  end)

  it("rejects a location containing ..", function()
    local ok, err = pcall(config.set, { locations = { "../../etc/passwd" } })
    assert.is_false(ok)
    assert.is_truthy(err:find("%.%."))
  end)

  it("rejects an absolute path location", function()
    local ok, err = pcall(config.set, { locations = { "/etc/passwd" } })
    assert.is_false(ok)
    assert.is_truthy(err:find("absolute"))
  end)

  it("accepts a normal relative location", function()
    local ok = pcall(config.set, { locations = { ".github/CODEOWNERS" } })
    assert.is_true(ok)
  end)

  it("accepts the default locations without error", function()
    local ok = pcall(config.set, { locations = config.defaults.locations })
    assert.is_true(ok)
  end)
end)
