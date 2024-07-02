defmodule Robots do
  def run_string(string) do
    StringIO.open(string, &run/1)
  end

  def run(device) do
    {grid, robots} = parse(device)
    process(robots, grid)
  end

  def parse(device) do
    {parse_grid(device), parse_robots(device)}
  end

  def parse_grid(device) do
    IO.read(device, :line)
    |> String.split()
    |> Enum.map(&parse_int!/1)
    |> List.to_tuple()
  end

  defp parse_int!(string) do
    {n, ""} = Integer.parse(string)
    n
  end

  def parse_robots(device, acc \\ []) do
    case IO.read(device, :line) do
      :eof ->
        Enum.reverse(acc)

      data ->
        case String.trim(data) do
          "" ->
            # skip whitespace
            parse_robots(device, acc)

          init_line ->
            case IO.read(device, :line) do
              :eof ->
                raise "should never happen"

              inst_line ->
                parse_robots(device, [parse_robot(init_line, String.trim(inst_line)) | acc])
            end
        end
    end
  end

  def parse_robot(init_line, inst_line) do
    [x, y, dir] = String.split(init_line)
    {{parse_int!(x), parse_int!(y), parse_dir(dir)}, parse_insts(inst_line)}
  end

  def parse_dir("N"), do: :N
  def parse_dir("E"), do: :E
  def parse_dir("S"), do: :S
  def parse_dir("W"), do: :W

  def parse_insts(string), do: Enum.map(String.graphemes(string), &parse_inst/1)

  def parse_inst("L"), do: :L
  def parse_inst("R"), do: :R
  def parse_inst("F"), do: :F

  def process(robots, grid, scents \\ MapSet.new())

  def process([], _grid, _scents) do
    :ok
  end

  def process([{init, insts} | rest], grid, scents) do
    {x, y, dir, lost_or_safe} = result = move(init, insts, grid, scents)

    IO.puts("#{x} #{y} #{dir}#{format_lost(lost_or_safe)}")
    process(rest, grid, next_scents(result, scents))
  end

  def next_scents({x, y, _, :lost}, scents), do: MapSet.put(scents, {x, y})
  def next_scents(_, scents), do: scents

  def format_lost(:lost), do: " LOST"
  def format_lost(:safe), do: ""

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
