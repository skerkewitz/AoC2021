#import ExUnit.Assertions

#filename = "input/day12-super-simple.txt"
#filename = "input/day12-simple.txt"
filename = "input/day12-real.txt"

defmodule Day12 do
	def split_str_to_tuple(s, pattern), do: String.split(s, pattern, trim: true) |> List.to_tuple()

	def create_revert_edges({s, e}), do: {e, s}
	def create_graph_from_file(filename) do
		File.stream!(filename) |> Enum.map(&String.trim/1) |> Enum.map(&(Day12.split_str_to_tuple(&1, "-")))
		|>Enum.map(fn e -> [e, create_revert_edges(e)] end)
		|> List.flatten()
	end

	def update_max_count(_, max_visit_count) when max_visit_count == 1, do: 1
	def update_max_count(visited, max_visit_count) do
		visited_something_more_than_once = Enum.frequencies(visited) |> Enum.any?(fn {_, v} -> v >= max_visit_count end)
		if visited_something_more_than_once, do: 1, else: max_visit_count
	end

	def can_visit_connection(search, _, _) when search == "start", do: false # can never visit start
	def can_visit_connection(search, visited, max_visit_count) do
		Enum.count(visited, &(search == &1)) < max_visit_count
	end

	def find_connections(l, s, visited, max_visit_count) do
		max_visit_count = update_max_count(visited, max_visit_count)
		connections = l |> Enum.filter(fn {path_start, _} -> s == path_start end)
		   							|> Enum.filter(fn {_, path_end} -> can_visit_connection(path_end, visited, max_visit_count) end)
		{max_visit_count, connections}
	end

	# if given start point is small cave then add it to visited list
	def update_visitor(s, visited) do if String.downcase(s) == s, do: [s | visited], else: visited end

	def find_path(_, s, e, current_path, _, _) when s == e, do: [Enum.join(Enum.concat(current_path, [s]), ",")]
	def find_path(l, s, e, current_path, visited, max_visit_count) do
		visited = update_visitor(s, visited)
		current_path = Enum.concat(current_path, [s])
		{max_visit_count, connections} = find_connections(l, s, visited, max_visit_count)
		connections
		|> Enum.map(fn {_, path_end} -> find_path(l, path_end, e, current_path, visited, max_visit_count) end)
		|> List.flatten()
  end
end

graph = Day12.create_graph_from_file(filename)
Day12.find_path(graph, "start", "end", [], [], 1) |> Enum.count() |> IO.inspect(label: "Part 1")
Day12.find_path(graph, "start", "end", [], [], 2) |> Enum.count() |> IO.inspect(label: "Part 2")


import ExUnit.Assertions
graph = Day12.create_graph_from_file("input/day12-super-simple.txt")
assert ["abcd,end"] == Day12.find_path([], "end", "end", ["abcd"], [], 1)
assert true == Day12.can_visit_connection("A", ["start"], 1)
assert false == Day12.can_visit_connection("A", ["start", "A"], 1)
assert true == Day12.can_visit_connection("A", ["start", "A"], 2)

assert {1, [{"A", "c"}, {"A", "b"}, {"A", "end"}]} == Day12.find_connections(graph, "A", [], 1)

assert {2, [{"A", "c"}, {"A", "b"}, {"A", "end"}]} == Day12.find_connections(graph, "A", ["c"], 2) # c is still allowed because first time we would visit twice
assert {1, [{"A", "b"}, {"A", "end"}]} == Day12.find_connections(graph, "A", ["c", "f", "f"], 2) #  c is not allowed because we already visited f twice