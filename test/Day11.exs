#import ExUnit.Assertions

#filename = "input/day11-super-simple.txt"
#filename = "input/day11-simple.txt"
filename = "input/day11-real.txt"

defmodule Day11 do
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)
	def get_at(array, x, y) do ye = Enum.at(array, y, nil); if ye == nil, do: nil, else: Enum.at(ye, x, nil) end
	def enumerate_map2d(list2d, fun \\ fn i -> i end) do
		for y <- 0..length(list2d) - 1 do
			for x <- 0..length(hd(list2d)) - 1 do
				fun.({x, y, get_at(list2d, x, y)})
			end
		end
	end

	def increase_level(g), do: enumerate_map2d(g, fn {_, _, e} -> e + 1 end)
	def cleanup(g, fc), do: {enumerate_map2d(g, fn {_, _, e} -> if e == -1, do: 0, else: e end), fc}
	def mark_flashed(g), do: enumerate_map2d(g, fn {_, _, e} -> if e > 9, do: -1, else: e end)

	def find_flash_pos(g) do
		g |> enumerate_map2d()
      |> List.flatten()
		  |> Enum.map(fn {x, y, e} -> {x, y, e > 9} end) # is flash pos?
		  |> Enum.filter(fn {_, _, f} -> f end) # keep only flash pos
		  |> Enum.map(fn {x, y, _} -> {x, y} end) # map to {x, y}
	end

	@flash_target_offsets  [{-1, -1}, {0, -1}, {1, -1},
		                      {-1,  0},          {1,  0},
                          {-1,  1}, {0,  1}, {1,  1}]

  def flash_target(flash_pos_list, grid) do
		flash_pos_list
		|> Enum.map(fn {xp, yp} -> Enum.map(@flash_target_offsets, fn {xo, yo} -> {xp + xo, yp + yo} end) end)
		|> List.flatten()
		|> Enum.filter(fn {x, y} -> e = get_at(grid, x, y); e != nil && e != -1 end) # remove out of bounds and already flashed
		|> Enum.frequencies()
	end

	def flash(g, flash_count) do
		flash_positions = find_flash_pos(g)
		marked_grid = mark_flashed(g)
		flash_target = flash_target(flash_positions, marked_grid)

		# Apply flash
		final_g = enumerate_map2d(marked_grid , fn {x, y, e} ->
			case flash_target[{x, y}] do
				f when f != nil -> e + f
				_ -> e
			end
		end)

		flash_count = flash_count + length(flash_positions)
		flash_again = final_g |> List.flatten() |> Enum.any?(fn e -> e > 9 end) # do we need a re-flash?
		if flash_again do
      flash(final_g, flash_count)
    else
			cleanup(final_g, flash_count) # remove marks
		end
	end

	def run_simulation_part1(m, fc, d, md) when d == md, do: {fc, m}
	def run_simulation_part1(m, fc, d, md) do
		{m, fc} = m |> Day11.increase_level() |> Day11.flash(fc) #|> IO.inspect(label: "Generation #{d+1}")
		run_simulation_part1(m, fc, d + 1, md)
	end

	def run_simulation_part2(m, d \\ 1) do
		{m, fc} = m |> Day11.increase_level() |> Day11.flash(0) #|> IO.inspect(label: "Generation #{d+1}")
		if fc == 100, do: d, else: run_simulation_part2(m, d+1)
	end
end

input = File.stream!(filename) |> Enum.map(&String.trim/1) |> Enum.map(fn s -> Day11.split_str_to_int(s, "") end)
input |> Day11.run_simulation_part1(0, 0, 100) |> elem(0) |> IO.inspect(label: "Part 1")
input |> Day11.run_simulation_part2() |> IO.inspect(label: "Part 2")