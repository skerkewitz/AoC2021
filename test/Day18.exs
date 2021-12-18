import ExUnit.Assertions
import Snailfish
#filename = "input/day18-real-simple.txt"
#filename = "input/day18-simple.txt"
#filename = "input/day18-real.txt"


defmodule Util do
	def split_str_to_tuple(s, pattern), do: String.split(s, pattern, trim: true) |> List.to_tuple()
	def split_str_to_ints(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)
	def string_list_to_charlist_list(str_list) do
		str_list |> Enum.map(fn s -> to_charlist(s) end)
	end
end


defmodule Day18 do


end

#input = File.stream!(filename) |> Enum.map(&String.trim/1) |> hd() #|> IO.inspect(label: "Input")

#start = [{0,0}]
##target_area = {{20,-10}, {30, -5}}
#target_area = {{155,-117}, {182, -67}}
#
#best =
#for y <- -117..300 do
#	for x <- 0..200 do
#		{x, y}
#	end
#end
#|> List.flatten()
#|> Enum.map(fn velocity -> {velocity, Day18.will_hit(start, velocity, target_area)} end)
#|> Enum.filter(fn {_, {hit, _}} -> hit == :yes end)
##|> Enum.max_by(fn {_, l} -> Enum.max_by(l, fn {x, y} -> y end) end)
#|> Enum.count()
#|> IO.inspect(label: "Best Part 2")

#Enum.max_by(elem(best, 1), fn {x, y} -> y end)
#|> IO.inspect(label: "Result Part 1")

#Day18.sum(data) |> IO.inspect(label: "Resul Part 1")


#assert {5, 2} == Day18.add_drag_and_gravity({6, 3})
#assert {0, -3} == Day18.add_drag_and_gravity({0, -2})
#assert {0, -1} == Day18.add_drag_and_gravity({-1, 0})
#
#assert {:yes, [{28, -7}, {27, -3}, {25, 0}, {22, 2}, {18, 3}, {13, 3}, {7, 2}, {0, 0}]} == Day18.will_hit(start, {7,2}, target_area)
#assert {:yes, [{21, -10}, {21, 0}, {21, 9}, {21, 17}, {21, 24}, {21, 30}, {21, 35}, {21, 39}, {21, 42}, {21, 44}, {21, 45}, {21, 45}, {21, 44}, {21, 42}, {21, 39}, {20, 35}, {18, 30}, {15, 24}, {11, 17}, {6, 9}, {0, 0}]} == Day18.will_hit(start, {6,9}, target_area)
##assert {:yes, [{21, -10}, {21, 0}, {21, 9}, {21, 17}, {21, 24}, {21, 30}, {21, 35}, {21, 39}, {21, 42}, {21, 44}, {21, 45}, {21, 45}, {21, 44}, {21, 42}, {21, 39}, {20, 35}, {18, 30}, {15, 24}, {11, 17}, {6, 9}, {0, 0}]} == Day18.will_hit(start, {7,9}, target_area)



#Decoder.create(input) |> Decoder.read() |>Day18.sum() |> IO.inspect(label: "Part 1")
#Decoder.create(input) |> Decoder.read() |>Day18.walk() |> IO.inspect(label: "Part 2")