describe("before_each", function()
  local value = 0

  before_each(function()
    value = value + 1
  end)

  it("is called", function()
    expect(value).toBe(1)
  end)

  it("is called again", function()
    expect(value).toBe(2)
  end)
end)

describe("after_each", function()
  local value = 0

  after_each(function()
    value = value + 1
  end)

  it("is called", function()
    expect(value).toBe(0)
  end)

  it("is called again", function()
    expect(value).toBe(1)
  end)
end)
