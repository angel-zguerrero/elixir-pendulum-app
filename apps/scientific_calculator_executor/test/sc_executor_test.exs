defmodule SCExecutorTest do
  use ExUnit.Case
  doctest SCExecutor

  test "greets the world" do
    assert SCExecutor.hello() == :world
  end
end
