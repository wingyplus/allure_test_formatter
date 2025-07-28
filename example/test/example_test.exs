defmodule ExampleTest do
  use ExUnit.Case
  doctest Example

  test "passed" do
    assert 1 = 1
  end

  test "failure" do
    assert {} = {1, 2}
  end

  test "exception" do
    raise "Exception in test"
  end

  @tag :skip
  test "skip" do
    assert 1 = 2
  end

  @tag :must_exclude
  test "exclude" do
    assert 1 = 2
  end
end
