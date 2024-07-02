defmodule Robots do
  def move(robot, insts, grid, scents \\ MapSet.new())

  def move({x, y, dir}, [], _grid, _scents) do
    {x, y, dir, :safe}
  end

  def move(robot, [inst | rest], grid, scents) do
    case step(robot, inst, grid) do
      {:ok, robot} ->
        move(robot, rest, grid, scents)

      {:error, _} ->
        if safe?(robot, scents) do
          move(robot, rest, grid, scents)
        else
          lost(robot)
        end
    end
  end

  def step(robot, :F, grid) do
    new = forward(robot)

    if out_of_bounds?(new, grid) do
      {:error, new}
    else
      {:ok, new}
    end
  end

  def step({x, y, dir}, tdir, _) when tdir in [:R, :L] do
    {:ok, {x, y, turn(dir, tdir)}}
  end

  def forward({x, y, :N = dir}), do: {x, y + 1, dir}
  def forward({x, y, :E = dir}), do: {x + 1, y, dir}
  def forward({x, y, :S = dir}), do: {x, y - 1, dir}
  def forward({x, y, :W = dir}), do: {x - 1, y, dir}

  def turn(dir, :L), do: turn_left(dir)
  def turn(dir, :R), do: turn_right(dir)

  def turn_right(:N), do: :E
  def turn_right(:E), do: :S
  def turn_right(:S), do: :W
  def turn_right(:W), do: :N

  def turn_left(:N), do: :W
  def turn_left(:E), do: :N
  def turn_left(:S), do: :E
  def turn_left(:W), do: :S

  def out_of_bounds?({x, y, _}, {gx, gy}) do
    x > gx or y > gy or x < 0 or y < 0
  end

  def lost({x, y, dir}) do
    {x, y, dir, :lost}
  end

  def safe?({x, y, _}, scents) do
    MapSet.member?(scents, {x, y})
  end
end
