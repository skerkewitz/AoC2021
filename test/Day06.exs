#filename = "input/day06-simple.txt"
filename = "input/day06-real.txt"

defmodule Day06 do
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)

	def sim_day_for_fish({timer, count}) do
		case timer - 1 do
			x when x >= 0 -> [{timer - 1, count}]
			_ -> [{6, count}, {8, count}]
		end
	end

	def optimize(l) do
		map = l |> Enum.group_by(fn {timer, count} -> timer end)
		Map.keys(map) |> Enum.map(fn k ->
			Map.get(map, k) |> Enum.reduce({k, 0}, fn {et, ec}, {at, ac} -> {at, ec + ac}
		end) end)
	end

	def sim_day(list, day) do
		sim_func = fn l -> l |> Enum.map(&sim_day_for_fish/1) |> List.flatten |> optimize end
		case day do
			d when d > 1 -> sim_day(sim_func.(list), d - 1)
			_ -> sim_func.(list)
		end
	end
end

input = File.stream!(filename) |> Enum.map(&String.trim/1)
				|> List.first
				|> Day06.split_str_to_int(",")
				|> Enum.frequencies
				|> Enum.map(fn {k, v} -> {k,v} end)

count = fn l -> l |> Enum.reduce(0, fn ({_, c}, a) -> a + c end) end
Day06.sim_day(input, 80) |> count.() |> IO.inspect(label: "Result 1")
Day06.sim_day(input, 256) |> count.() |> IO.inspect(label: "Result 2")
