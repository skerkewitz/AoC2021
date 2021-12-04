use Bitwise

#filename = "input/day03-simple.txt"
filename = "input/day03-real.txt"

input = File.stream!(filename) |> Enum.map(&String.trim/1)
integer_at = &(String.at(&1, &2) |> String.to_integer())

bit_count = fn
	0, {l, h} -> {l + 1, h}
	1, {l, h} -> {l, h + 1}
end

defmodule Day03 do

	def bool_to_int(bool), do: (if bool, do: "1", else: "0")
	def int_at(str, n), do: String.at(str, n) |> String.to_integer()

	def red(elm, acc) do
		greater = elm[0] > elm[1]
		{g, e} = acc
    {g <> bool_to_int(greater), e <> bool_to_int(!greater)}
  end
end

## First part

len = (List.first(input) |> String.length()) - 1

count = for n <- 0..len do
	        input
	        |> Enum.map(&(Day03.int_at(&1, n)))
	        |> Enum.frequencies()
        end
        |> Enum.reduce({"0", "0"}, &(Day03.red/2))
				|> Tuple.to_list()
				|> Enum.map(&(String.to_integer(&1, 2)))
				|> Enum.reduce(&(&1 * &2))

IO.puts("Result is #{inspect(count)}")

# Second part
oxygen_keeper = fn
	{l, h} when l > h -> 0
	{l, h} when l < h -> 1
	{l, h} when l == h -> 1
end

co2_keeper = fn
	{l, h} when l < h -> 0
	{l, h} when l > h -> 1
	{l, h} when l == h -> 0
end

recursive_fold = fn (l, n, self, keeper) ->
	keep = l
	       |> Enum.map(&(integer_at.(&1, n)))
	       |> Enum.reduce({0, 0}, bit_count)
				 |> keeper.()
			   |> IO.inspect(label: "Keep")

	fl = l |> Enum.filter(&(integer_at.(&1, n) == keep))

	case length(fl) do
		1 -> String.to_integer(List.first(fl), 2)
		_ -> self.(fl, n+ 1, self, keeper)
	end
end

result = recursive_fold.(input, 0, recursive_fold, oxygen_keeper) * recursive_fold.(input, 0, recursive_fold, co2_keeper)
IO.puts("Result is #{inspect(result)}")
