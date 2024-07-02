defmodule RobotsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

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

  test "parse" do
    assert StringIO.open("5 3\n\n1 1 E\nRFRF", &Robots.parse/1) ==
             {:ok, {{5, 3}, [{{1, 1, :E}, [:R, :F, :R, :F]}]}}
  end

  test "run" do
    assert capture_io(fn ->
             Robots.run_string("""
             5 3

             1 1 E
             RFRFRFRF
             """)
           end) == "1 1 E\n"

    {:ok, device} = StringIO.open(File.read!(Path.join(__DIR__, "example.input")))
    assert capture_io(fn -> Robots.run(device) end) == File.read!(Path.join(__DIR__, "example.output"))
  end
end
