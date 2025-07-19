defmodule AllureTestFormatterTest do
  use ExUnit.Case
  doctest AllureTestFormatter

  test "greets the world" do
    assert AllureTestFormatter.hello() == :world
  end
end
