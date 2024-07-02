defmodule RobotsTest do
  use ExUnit.Case

  # 5 3

  # 1 1 E
  # RFRFRFRF

  # 3 2 N
  # FRRFLLFFRRFLL

  # 0 3 W
  # LLFFFLFLFL

  # 1 1 E
  # 3 3 N LOST
  # 2 3 S

  test "move" do
    grid = {5, 3}
    assert {1, 1, :E, :safe} = Robots.move({1, 1, :E}, [:R, :F, :R, :F, :R, :F, :R, :F], grid)

    assert {3, 3, :N, :lost} =
             Robots.move({3, 2, :N}, [:F, :R, :R, :F, :L, :L, :F, :F, :R, :R, :F, :L, :L], grid)

    assert {2, 3, :S, :safe} =
             Robots.move(
               {0, 3, :W},
               [:L, :L, :F, :F, :F, :L, :F, :L, :F, :L],
               grid,
               MapSet.new([{3, 3}])
             )
  end
end
