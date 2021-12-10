import ExUnit.Assertions

filename = "input/day10-simple.txt"
#filename = "input/day10-real.txt"

defmodule Day10 do
	@close_char %{?( => ?), ?[ => ?], ?{ => ?}, ?< => ?>}
	@score_table_part1 %{?) => 3, ?] => 57, ?} => 1197, ?> => 25137}
	@score_table_part2 %{?) => 1, ?] => 2, ?} => 3, ?> => 4}

	def scan(input, stack) when input == [], do: {:ok, stack}
	def scan(input, stack) do
		[h | t] = input
		end_char = @close_char[h];

		if !is_nil(end_char) do
			# Is opening char, push to stack and scan remaining
			scan(t, [end_char | stack])
		else
			# No elements on stack left, there is no match
			if length(stack) == 0 do
        {:failed, h}
			else
				if hd(stack) == h, do: scan(t, tl(stack)), else: {:failed, h}
			end
		end
	end

	def scan(s), do: scan(to_charlist(s), [])

	def score_scan(s) do
		case scan(s) do
			{:ok, _} -> 0
			{:failed, c} -> @score_table_part1[c]
		end
	end

	def score_for_stack(s), do: s |> Enum.reduce(0, fn c, a -> (a * 5) + @score_table_part2[c] end)
end

input = File.stream!(filename)
        |> Enum.map(&String.trim/1)

#Part 1
input
|> Enum.map(fn s -> Day10.score_scan(s) end)
|> Enum.sum()
|> IO.inspect(label: "Part 1")

# Part 2
score_list = input
             |> Enum.map(fn s -> Day10.scan(s) end)
             |> Enum.filter(fn {x, _} -> x == :ok end)
             |> Enum.map(fn {_, s} -> Day10.score_for_stack(s) end)
             |> Enum.sort()

winner_pos = div(length(score_list), 2)
Enum.at(score_list, winner_pos) |> IO.inspect(label: "Part 2")



assert 294 == Day10.score_for_stack([?], ?), ?}, ?>])


assert {:ok, []} == Day10.scan("[]")
assert {:ok, []} == Day10.scan("[][]")

assert {:ok, []} == Day10.scan("{([])<[]>}")

assert {:failed, ?]} == Day10.scan("]")
assert {:failed, ?]} == Day10.scan("()]")

assert {:failed, ?}} == Day10.scan("{([(<{}[<>[]}>{[]{[(<()>")

assert {:ok, [?]]} == Day10.scan("[")



#assert {:ok, []} == Day10.is_valid_chunk(to_charlist("[]"))
#assert {:ok, []} == Day10.is_valid_chunk(to_charlist("[][]"))

#assert {:ok, []} == Day10.is_valid_chunk(to_charlist("{([])<[]>}"))

#assert {:failed, ?], [?]]} == Day10.is_valid_chunk(to_charlist("]"))
#assert {:failed, ?], [?]]} == Day10.is_valid_chunk(to_charlist("()]"))

#assert {:ok, []} == Day10.expect(to_charlist("]"), ?])
#assert {:ok, []} == Day10.expect(to_charlist("()]"), ?])
#assert {:ok, []} == Day10.expect(to_charlist("()()]"), ?])

#assert {:failed, ?}, []} == Day10.is_valid_chunk(to_charlist("{([(<{}[<>[]}>{[]{[(<()>"))


#assert {:failed, ?}, []} == Day10.is_valid_chunk(to_charlist("{([])<[]>}"))



#assert {:ok, []} == Day10.is_valid_chunk(to_charlist("[()]"))

#assert {:failed, ?<} == Day10.is_valid_chunk(to_charlist("[(<)]"))

##Part 1
#low_points
#|> Enum.map(fn {_, _, v} -> v + 1 end)
#|> Enum.sum()
#|> IO.inspect(label: "Result 1")
#
##Part 2
#low_points
#|> Enum.map(fn {x, y, _} -> MapSet.size(Day09.basin(input, ({x, y}))) end)
#|> Enum.sort(:desc) |> Enum.take(3) |> Enum.reduce(1, fn e, a -> e * a end)
#|> IO.inspect(label: "Result 2")