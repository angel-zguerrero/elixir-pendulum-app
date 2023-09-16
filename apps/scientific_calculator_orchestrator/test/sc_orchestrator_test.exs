defmodule SCOrchestratorTest do
  use ExUnit.Case
  doctest SCOrchestrator

  test "greets the world" do
    assert SCOrchestrator.hello() == :world
  end
end
