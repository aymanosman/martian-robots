defmodule RobotsTest do
  use ExUnit.Case
  doctest Robots

  test "greets the world" do
    assert Robots.hello() == :world
  end
end
