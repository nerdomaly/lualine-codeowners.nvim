local parser = require("lualine-codeowners.parser")

local function matches_any(glob, path)
  for _, p in ipairs(parser.glob_to_lua(glob)) do
    if path:match(p) then return true end
  end
  return false
end

describe("glob_to_lua", function()
  describe("* (bare star)", function()
    it("matches foo.txt", function()
      assert.is_true(matches_any("*", "foo.txt"))
    end)
    it("matches a/b/c.txt", function()
      assert.is_true(matches_any("*", "a/b/c.txt"))
    end)
    it("matches README.md", function()
      assert.is_true(matches_any("*", "README.md"))
    end)
  end)

  describe("*.js", function()
    it("matches foo.js", function()
      assert.is_true(matches_any("*.js", "foo.js"))
    end)
    it("matches a/b.js", function()
      assert.is_true(matches_any("*.js", "a/b.js"))
    end)
    it("does not match foo.jsx", function()
      assert.is_false(matches_any("*.js", "foo.jsx"))
    end)
    it("does not match foo.json", function()
      assert.is_false(matches_any("*.js", "foo.json"))
    end)
  end)

  describe("/README.md (anchored)", function()
    it("matches README.md at root", function()
      assert.is_true(matches_any("/README.md", "README.md"))
    end)
    it("does not match sub/README.md", function()
      assert.is_false(matches_any("/README.md", "sub/README.md"))
    end)
  end)

  describe("docs/ (trailing slash = directory)", function()
    it("matches docs/x.md", function()
      assert.is_true(matches_any("docs/", "docs/x.md"))
    end)
    it("matches docs/a/b.md", function()
      assert.is_true(matches_any("docs/", "docs/a/b.md"))
    end)
    it("does not match bare 'docs'", function()
      assert.is_false(matches_any("docs/", "docs"))
    end)
  end)

  describe("docs (no slash)", function()
    it("matches docs itself", function()
      assert.is_true(matches_any("docs", "docs"))
    end)
    it("matches docs/x.md", function()
      assert.is_true(matches_any("docs", "docs/x.md"))
    end)
    it("matches a/docs/y.md", function()
      assert.is_true(matches_any("docs", "a/docs/y.md"))
    end)
  end)

  describe("src/modules/alpha (segment boundaries)", function()
    it("matches src/modules/alpha itself", function()
      assert.is_true(matches_any("src/modules/alpha", "src/modules/alpha"))
    end)
    it("matches src/modules/alpha/foo.tsx", function()
      assert.is_true(matches_any("src/modules/alpha", "src/modules/alpha/foo.tsx"))
    end)
    it("does not match src/modules/alpha-extra/x.ts", function()
      assert.is_false(matches_any("src/modules/alpha", "src/modules/alpha-extra/x.ts"))
    end)
  end)

  describe("**/*.tsx", function()
    it("matches a/b.tsx", function()
      assert.is_true(matches_any("**/*.tsx", "a/b.tsx"))
    end)
    it("matches x.tsx at root", function()
      assert.is_true(matches_any("**/*.tsx", "x.tsx"))
    end)
  end)

  describe("** segment normalization (ReDoS prevention)", function()
    it("collapses **/**/**/**/*.js to the same patterns as **/*.js", function()
      local single = parser.glob_to_lua("**/*.js")
      local many   = parser.glob_to_lua("**/**/**/**/*.js")
      assert.same(single, many)
    end)

    it("still matches paths correctly after normalization", function()
      assert.is_true(matches_any("**/**/**/*.js",  "a/b/c/d.js"))
      assert.is_true(matches_any("**/**/**/*.js",  "d.js"))
      assert.is_false(matches_any("**/**/**/*.js", "a/b.jsx"))
    end)
  end)
end)

describe("parse_file", function()
  it("parses simple CODEOWNERS", function()
    local fixture = vim.fn.fnamemodify(
      debug.getinfo(1, "S").source:sub(2),
      ":h"
    ) .. "/fixtures/simple/.github/CODEOWNERS"
    local rules = parser.parse_file(fixture)
    assert.equals(1, #rules)
    assert.same({ "@everyone" }, rules[1].owners)
  end)

  it("parses complex CODEOWNERS skipping comments and blanks", function()
    local fixture = vim.fn.fnamemodify(
      debug.getinfo(1, "S").source:sub(2),
      ":h"
    ) .. "/fixtures/complex/.github/CODEOWNERS"
    local rules = parser.parse_file(fixture)
    assert.equals(4, #rules)
    assert.same({ "@team/all", "@team/leads" }, rules[1].owners)
    assert.same({ "@team/one", "@team/two" }, rules[4].owners)
  end)
end)
