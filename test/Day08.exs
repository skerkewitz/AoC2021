#filename = "input/day08-simple.txt"
filename = "input/day08-real.txt"

defmodule Day08 do
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)

	def decode_simple(s) do
		case String.length(s) do
			s when s == 2 -> 1
			s when s == 3 -> 7
			s when s == 4 -> 4
			s when s == 7 -> 8
			_ -> nil
		end
	end

	def remove_solve(l, solved), do: l |> Enum.filter(fn e -> e not in (solved |> Map.values()) end)

	def decode_pattern(p) do

		# sort input, build known map, remove solved from input
		sp = p |> Enum.map(fn s -> s |> to_charlist() |> Enum.sort() |> to_string() end)
		solved = sp |> Enum.map(fn e -> {decode_simple(e), e} end) |> Enum.filter(fn {n, _} -> n != nil end) |> Enum.into(%{})
		rp = remove_solve(sp, solved)

		# Solve 3 - has to be 5 segments and each segment of 7 need to be in 3
		three = rp |> Enum.filter(fn s -> String.length(s) == 5 end)
		           |> Enum.filter(fn s -> to_charlist(solved[7]) |> Enum.all?(fn x -> x in to_charlist(s) end) end)
		           |> List.first()

		solved = Map.put(solved, 3, three)
		rp = remove_solve(rp, solved)

		# Solve 9 - has to be 6 segments and each segment of 3 need to be in 9
		nine = rp |> Enum.filter(fn s -> String.length(s) == 6 end)
		          |> Enum.filter(fn s -> to_charlist(solved[3]) |> Enum.all?(fn x -> x in to_charlist(s) end) end)
		          |> List.first()

		solved = Map.put(solved, 9, nine)
		rp = remove_solve(rp, solved)

		# Solve 5 - has to be 5 segments
		five = rp |> Enum.filter(fn s -> String.length(s) == 5 end)
		          |> Enum.filter(fn s -> s |> to_charlist() |> Enum.all?(fn x -> x in to_charlist(solved[9]) end) end)
		          |> List.first()

		solved = Map.put(solved, 5, five)
		rp = remove_solve(rp, solved)

		# Solve 2 the remaining one with 5 segments
		two = rp |> Enum.filter(fn s -> String.length(s) == 5 end)
		         |> List.first()

		solved = Map.put(solved, 2, two)
		rp = remove_solve(rp, solved)

		# Solve 6
		mask_charlist = solved[4] |> to_charlist() |> Enum.filter(fn s -> s not in (to_charlist(solved[1])) end)
		six = rp |> Enum.filter(fn s -> mask_charlist |> Enum.all?(fn c -> c in to_charlist(s) end) end)
		         |> List.first()

		solved = Map.put(solved, 6, six)
		rp = remove_solve(rp, solved)

		# Solve 0 the only one left
		solved = Map.put(solved, 0, List.first(rp))
		solved
	end

	def decode_pattern(p, dc) do
		# sort input
		sp = p |> Enum.map(fn s -> s |> to_charlist() |> Enum.sort() |> to_string() end) #|> IO.inspect(label: "Sorted")
				   |> Enum.map(fn s -> Enum.filter(dc, fn {k, v} -> v == s end) |> hd() end)
		       |> Enum.map(fn {k, v} -> Integer.to_string(k) end) #|> IO.inspect(label: "TT")
					 |> Enum.join()
	end

	def solve_entry({p, v}) do
		p = p |> String.split(" ", trim: true)# |> IO.inspect(label: "P")
		v = v |> String.split(" ", trim: true)# |> IO.inspect(label: "V")
		dc = p |> Day08.decode_pattern()# |> IO.inspect(label: "Decode map")
		Day08.decode_pattern(v, dc) |> String.to_integer()
	end
end

input = File.stream!(filename)
        |> Enum.map(&String.trim/1)
				|> Enum.map(&(String.split(&1, " | ", trim: true) |> List.to_tuple()))
        #|> IO.inspect(label: "Input")

#Part 1
input |> Enum.map(fn {_, r} -> r |> String.split(" ", trim: true) end)
			|> List.flatten()
			|> Enum.map(&Day08.decode_simple/1)
			|> Enum.count(fn p -> p != nil end)
      |> IO.inspect(label: "Result 1")

#Part 2
input |> Enum.map(&Day08.solve_entry/1)
			|> Enum.sum()
      |> IO.inspect(label: "Result 2")

import ExUnit.Assertions
assert Day08.decode_simple("gcbe") == 4
assert Day08.decode_simple("gc") == 1
assert Day08.decode_simple("dgebacf") == 8
assert Day08.decode_simple("cgb") == 7
assert Day08.decode_simple("cf") == 1
assert Day08.decode_simple("c") == nil