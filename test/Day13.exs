#import ExUnit.Assertions

#filename = "input/day13-super-simple.txt"
#filename = "input/day13-simple.txt"
filename = "input/day13-real.txt"

defmodule DataMap do

	def create(data_list) do
		data_list
		|> String.split("\n", trim: true)
		|> Enum.map(&({(Day13.split_str_to_int(&1, ",") |> List.to_tuple()), true}))
		|> Enum.into(%{})
	end

	def print(data_map) do
		{{max_x, _}, _} = data_map |> Enum.max_by(fn {{x, _}, _} -> x end)
		{{_, max_y}, _} = data_map |> Enum.max_by(fn {{_, y}, _} -> y end)

		for y <- 0..max_y do
			for x <- 0..max_x do
				if data_map[{x,y}] != nil, do: IO.write("#"), else: IO.write(".")
			end
			IO.puts("")
		end
		data_map
	end

	def fold_coords_horizontal(coords, y_fold_point), do: coords |> Enum.map(fn {x, y} -> {x, y_fold_point - (y - y_fold_point)} end)
	def fold_coords_vertical(coords, x_fold_point), do: coords |> Enum.map(fn {x, y} -> {x_fold_point - (x - x_fold_point), y} end)

	def fold_horizontal(data_map, y_fold_point) do

		{{_, max_y}, _} = data_map |> Enum.max_by(fn {{_, y}, _} -> y end)
    IO.puts("Fold horizontal at y #{y_fold_point}")

		# find all entry that needs to be folded
		needs_to_be_folded = Map.keys(data_map) |> Enum.filter(fn {_, y} -> y >= y_fold_point end) #|> IO.inspect(label: "Need to be folded")

		# remove position that need to be folded from map
		clean_data_map = data_map |> Map.drop(needs_to_be_folded) #|> IO.inspect(label: "Cleaned map")

		# re-map fold position
		folded = needs_to_be_folded |> fold_coords_horizontal(y_fold_point)

		# add re-mapped fold position to map
		folded |> Enum.map(fn {x, y} -> {{x, y}, true} end) |> Enum.into(clean_data_map)
	end

	def fold_vertical(data_map, x_fold_point) do

		{{max_x, _}, _} = data_map |> Enum.max_by(fn {{x, _}, _} -> x end)
		IO.puts("Fold horizontal at x #{x_fold_point}")

		# find all entry that needs to be folded
		needs_to_be_folded = Map.keys(data_map) |> Enum.filter(fn {x, _} -> x >= x_fold_point end) #|> IO.inspect(label: "Need to be folded")

		# remove position that need to be folded from map
		clean_data_map = data_map |> Map.drop(needs_to_be_folded) #|> IO.inspect(label: "Cleaned map")

		# re-map fold position
		folded = needs_to_be_folded |> fold_coords_vertical(x_fold_point)

		# add re-mapped fold position to map
		folded |> Enum.map(fn {x, y} -> {{x, y}, true} end) |> Enum.into(clean_data_map)
	end
end

defmodule Day13 do
	def split_str_to_tuple(s, pattern), do: String.split(s, pattern, trim: true) |> List.to_tuple()
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)

	def scan_instructions(instruction) do
		instruction #|> IO.inspect(label: "instruction in")
		|> Enum.map(fn s -> s |> String.split(" ", trim: true) |> List.last() end)
		|> Enum.map(fn s -> s |> String.split("=", trim: true) |> List.to_tuple() end)
		|> Enum.map(fn {i, v} -> {i, String.to_integer(v)} end)
		#|> IO.inspect(label: "instruction out")
	end

	def fold_with_instruction(map_data, instruction) do
		case instruction do
			{"x", x} -> DataMap.fold_vertical(map_data, x)
			{"y", y} -> DataMap.fold_horizontal(map_data, y)
		end
	end


	def fold(map_data, instruction) do
		instruction |> List.foldl(map_data, fn e, a -> fold_with_instruction(a, e) end)
	end
end

{data, instruction} = File.stream!(filename) |> Enum.map(&String.trim/1) |> Enum.join("\n") |> String.split("\n\n", trim: true) |> List.to_tuple()


data |> String.split("\n", trim: true) |> IO.inspect(label: "data")
instruction = instruction |> String.split("\n", trim: true) |> Day13.scan_instructions() |> IO.inspect(label: "instruction")

map_data = data |> DataMap.create() #|> DataMap.print()
#Day13.fold(map_data, instruction, 1) |> IO.inspect(label: "Result Part 1")

Day13.fold_with_instruction(map_data, hd(instruction)) |> Map.size()|> IO.inspect(label: "Result Part 1")
Day13.fold(map_data, instruction) |> DataMap.print() # Prints result Part 2

#Day13.fold(map_data, instruction, 1)


#|>Enum.map(fn e -> [e, create_revert_edges(e)] end)
#|> List.flatten()


#graph = Day13.create_graph_from_file(filename)
#Day13.find_path(graph, "start", "end", [], [], 1) |> Enum.count() |> IO.inspect(label: "Part 1")
#Day13.find_path(graph, "start", "end", [], [], 2) |> Enum.count() |> IO.inspect(label: "Part 2")

#import ExUnit.Assertions
#graph = Day13.create_graph_from_file("input/day13-super-simple.txt")
#assert ["abcd,end"] == Day13.find_path([], "end", "end", ["abcd"], [], 1)
#assert true == Day13.can_visit_connection("A", ["start"], 1)
#assert false == Day13.can_visit_connection("A", ["start", "A"], 1)
#assert true == Day13.can_visit_connection("A", ["start", "A"], 2)
#
#assert {1, [{"A", "c"}, {"A", "b"}, {"A", "end"}]} == Day13.find_connections(graph, "A", [], 1)
#
#assert {2, [{"A", "c"}, {"A", "b"}, {"A", "end"}]} == Day13.find_connections(graph, "A", ["c"], 2) # c is still allowed because first time we would visit twice
#assert {1, [{"A", "b"}, {"A", "end"}]} == Day13.find_connections(graph, "A", ["c", "f", "f"], 2) #  c is not allowed because we already visited f twice

#assert [{0,7}, {0, 6}] == DataMap.fold_coords_horizontal([{0, 7}, {0, 8}], 7)
