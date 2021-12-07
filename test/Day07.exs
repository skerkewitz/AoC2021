#filename = "input/day07-simple.txt"
filename = "input/day07-real.txt"

defmodule Day07 do
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)

	def cost_func1(start, pos), do: abs(start - pos)
	def cost_func2(start, pos), do: 1..abs(start - pos) |> Enum.sum()
	def calc_fuel_cost(l, p, f), do: l |> Enum.map(fn elem -> f.(elem, p) end) |> Enum.sum()

	def find_min_fuel_costs_entry(l, cost_func) do
		Enum.min(l)..Enum.max(l)
		  |> Enum.map(fn start_pos -> {start_pos, calc_fuel_cost(l, start_pos, cost_func)} end)
			|> Enum.min(fn {_ , f1}, {_, f2} -> f1 < f2 end)
	end

end

input = File.stream!(filename) |> Enum.map(&String.trim/1) |> List.first |> Day07.split_str_to_int(",")

Day07.find_min_fuel_costs_entry(input, &Day07.cost_func1/2) |> elem(1) |> IO.inspect(label: "Result 1")
Day07.find_min_fuel_costs_entry(input, &Day07.cost_func2/2) |> elem(1) |> IO.inspect(label: "Result 2")


