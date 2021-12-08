#filename = "input/day08-simple.txt"
filename = "input/day08-real.txt"

defmodule Day08 do
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)
	def make_map_set_from_string(str), do: str |> String.split(" ", trim: true) |> Enum.map(&(MapSet.new(to_charlist(&1))))
	def make_map_set_tuple({p, v}) , do: {make_map_set_from_string(p), make_map_set_from_string(v)}

	def decode_simple(s) do
		case MapSet.size(s) do
			s when s == 2 -> 1; s when s == 3 -> 7; s when s == 4 -> 4; s when s == 7 -> 8; _ -> nil
		end
	end

	def remove_solve(l, solved), do: l |> Enum.filter(fn e -> e not in (solved |> Map.values()) end)
	def decode_pattern_segments(l, segments, f), do: l |> Enum.filter(fn s -> MapSet.size(s) == segments && f.(s) end) |> hd()

  def prune_and_update(map, k, l, sc, f) do
	  solved = Map.put(map, k, decode_pattern_segments(l, sc, f))
		{solved, remove_solve(l, solved)}
	end

	def build_decoder_map(p) do
		# sort input, build known map, remove solved from input
    solved = p |> Enum.map(fn e -> {decode_simple(e), e} end)
               |> Enum.filter(fn {n, _} -> n != nil end) |> Enum.into(%{})
		rp = remove_solve(p, solved)

		# Solve 3 - has to be 5 segments and each segment of 7 need to be in 3
		{solved, rp} = prune_and_update(solved, 3, rp, 5, fn s -> MapSet.subset?(solved[7], s) end)

		# Solve 9 - has to be 6 segments and each segment of 3 need to be in 9
		{solved, rp} = prune_and_update(solved, 9, rp, 6, fn s -> MapSet.subset?(solved[3], s) end)

		# Solve 5 - has to be 5 segments and each segment of 5 need to be in 9
		{solved, rp} = prune_and_update(solved, 5, rp, 5, fn s -> MapSet.subset?(s, solved[9]) end)

		# Solve 2 the remaining one with 5 segments
		{solved, rp} = prune_and_update(solved, 2, rp, 5, fn _ -> true end)

		# Solve 0: 0 has to be 6 segments and all segments of 1 need to be in 0
		{solved, rp} = prune_and_update(solved, 0, rp, 6, fn s -> MapSet.subset?(solved[1], s) end)

		# Solve 6: 6 is the remaining entry with 6 segments
		{solved, _ } = prune_and_update(solved, 6, rp, 6, fn _ -> true end)
		solved
	end

	def decode_pattern(p, dc), do: Enum.map(p, fn s -> Enum.find(dc, fn {_, v} -> v == s end) |> elem(0) |> Integer.to_string() end) |> Enum.join()
end

input = File.stream!(filename) |> Enum.map(&String.trim/1) |> Enum.map(&(String.split(&1, " | ", trim: true) |> List.to_tuple()))

#Part 1
input |> Enum.map(fn {_, r} -> r |> String.split(" ", trim: true) end)
			|> List.flatten()
			|> Enum.map(&(Day08.decode_simple(MapSet.new(to_charlist(&1)))))
			|> Enum.count(fn p -> p != nil end)
      |> IO.inspect(label: "Result 1")

##Part 2
input |> Enum.map(&Day08.make_map_set_tuple/1)
			|> Enum.map(fn {p, v} -> Day08.decode_pattern(v, Day08.build_decoder_map(p)) |> String.to_integer() end)
			|> Enum.sum()
      |> IO.inspect(label: "Result 2")
