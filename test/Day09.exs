#filename = "input/day09-simple.txt"
filename = "input/day09-real.txt"

defmodule Day09 do
	def ascii_to_digit(ascii) when ascii >= 48 and ascii < 58, do: ascii - 48

	@spec get_at(integer, integer, integer) :: boolean
	def get_at(array, x, y) do
		if (x < 0 or y < 0) do
			nil
		else
			yl = Enum.at(array, y, nil); if yl == nil, do: nil, else: Enum.at(yl, x, nil)
		end
	end

	def is_lowpoint(a, x, y) do
		[{0, -1}, {-1, 0}, {1, 0}, {0, 1}]
		|> Enum.map(fn {j, k} -> get_at(a, x + j, y + k) end)
		|> Enum.filter(fn e -> e != nil end)
		|> Enum.all?(fn e -> e > get_at(a, x, y) end)
	end

	# ::L = ::List<::integer*>
	# %l = ::List<::L*>
	# %visited = ::Set<{::integer, ::integer}>
	def basin_rec(l, {x, y}, visited) do
		if MapSet.member?(visited, {x, y}) do
			{visited, []} # already checked
		else
			visited = MapSet.put(visited, {x, y})
			e = get_at(l, x, y)
			if e == nil or e == 9 do
				{visited, []} # recursion ends here
			else
				{visited, r1} = basin_rec(l, {x, y - 1}, visited) # up
				{visited, r2} = basin_rec(l, {x - 1, y}, visited) # left
				{visited, r3} = basin_rec(l, {x + 1, y}, visited) # right
				{visited, r4} = basin_rec(l, {x, y + 1}, visited) # down
				{visited, [{x, y} | r1 ++ r2 ++ r3 ++ r4]} # basin is this point + all the basin for adjacent fields
			end
		end
	end

	def basin(l, {x, y}) do
		{_, r} = basin_rec(l, {x, y}, MapSet.new())
		MapSet.new(r)
	end
end

input = File.stream!(filename) |> Enum.map(&String.trim/1) |> Enum.map(fn s -> Enum.map(to_charlist(s), &Day09.ascii_to_digit/1) end)
len_y = length(input)
len_x = length(hd(input))
low_points = for y <- 0..len_y - 1 do
              for x <- 0..len_x - 1, do: {x, y, Day09.get_at(input, x, y)}
             end
             |> List.flatten()
             |> Enum.filter(fn {x, y, _} -> Day09.is_lowpoint(input, x, y) end)

#Part 1
low_points
|> Enum.map(fn {_, _, v} -> v + 1 end)
|> Enum.sum()
|> IO.inspect(label: "Result 1")

#Part 2
low_points
|> Enum.map(fn {x, y, _} -> MapSet.size(Day09.basin(input, ({x, y}))) end)
|> Enum.sort(:desc) |> Enum.take(3) |> Enum.reduce(1, fn e, a -> e * a end)
|> IO.inspect(label: "Result 2")