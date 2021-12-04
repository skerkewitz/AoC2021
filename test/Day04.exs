#filename = "input/day04-simple.txt"
filename = "input/day04-real.txt"

defmodule Day04 do
	def split_str_to_int(l, pattern) do String.split(l, pattern, trim: true) |> Enum.map(&(String.to_integer(&1))) end
	def convert_field(l) do l |> Enum.map(fn s -> split_str_to_int(s, " ") |> Enum.map(&({&1, false})) end) end
	def is_winner(l) do Enum.count(l, fn {_,b} -> b end) == 5 end
	def is_winner_field(field) do
		has_winner_row = field |> Enum.map(&is_winner/1) |> Enum.member?(true)
		has_winner_column = for n <- 0..4 do field |> Enum.map(&(Enum.at(&1, n))) end
												|> Enum.map(&is_winner/1) |> Enum.member?(true)
		has_winner_row || has_winner_column
  end

	def mark_line(l, n) do l |> Enum.map(fn {x, b} -> {x, b || x == n} end) end
	def mark_field(field, n) do field |> Enum.map(fn l -> mark_line(l, n) end) end
  def mark_fields(fields, n) do fields |> Enum.map(fn field -> mark_field(field, n) end) end

	def draw_number_until_winner(fields, numbers, last_number) do
		winner_field = fields |> Enum.filter(&is_winner_field/1)
		case length(winner_field) do
			x when x > 0 -> {List.first(winner_field), last_number}
			_ -> draw_number_until_winner(mark_fields(fields, hd(numbers)), tl(numbers), hd(numbers))
		end
	end

	def find_last_field(fields, numbers) do
		non_winner_field = fields |> Enum.filter(&(!is_winner_field(&1)))
		case length(non_winner_field) do
			x when x == 1 -> draw_number_until_winner(non_winner_field, numbers, nil)
			_ -> find_last_field(mark_fields(fields, hd(numbers)), tl(numbers))
		end
	end

	def calc_winner_score(field) do
		field |> List.flatten() |> Enum.filter(fn {_, b} -> !b end) |> Enum.map(fn {v,_} -> v end) |> Enum.sum()
	end
end

input = File.stream!(filename) |> Enum.map(&String.trim/1) |> Enum.chunk_by(&(&1 == "")) |> Enum.filter(&(&1 != [""]))
[drawn | fields] = input
drawn = drawn |> Enum.map(fn s -> Day04.split_str_to_int(s, ",") end) |> List.flatten()
fields = fields |> Enum.map(&Day04.convert_field/1)

# Part 1:
{winner_field, winning_number} = Day04.draw_number_until_winner(fields, drawn, nil)
Day04.calc_winner_score(winner_field) * winning_number |> IO.inspect(label: "Result 1")

# Part 2:
{winner_field, winning_number} = Day04.find_last_field(fields, drawn)
Day04.calc_winner_score(winner_field) * winning_number |> IO.inspect(label: "Result 2")