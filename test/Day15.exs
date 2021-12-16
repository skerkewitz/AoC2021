#import ExUnit.Assertions

#filename = "input/day15-real-simple.txt"
#filename = "input/day15-simple.txt"
filename = "input/day15-real.txt"

defmodule DataMap do
	def create(data_list) do
		max_y = length(data_list) #|> IO.inspect(label: "Max Y")

		for ey <- 0..4 do
			data_list
			|> Enum.with_index()
			#|> IO.inspect(label: "Input")
			|> Enum.map(fn {l, y} ->
				for ex <- 0..4 do
					codepoints = l |> String.codepoints
					max_x = length(codepoints) #|> IO.inspect(label: "Max X")
						codepoints |> Enum.chunk_every(1, 1, :discard) |> Enum.with_index()
	         |> Enum.map(fn {s, x} ->
		         v = String.to_integer(Enum.join(s)) + ex + ey
		         v = if v > 9, do: v - 9, else: v
		         {{x + ((max_x) * ex), y + ((max_y) * ey)}, v}
	         end)
	      end
	      |> List.flatten()
			end)
			|> List.flatten()
		end
		|> List.flatten()
		|> Enum.into(%{})
	end

	def get_size(data_map) do
		{{max_x, _}, _} = data_map |> Enum.max_by(fn {{x, _}, _} -> x end)
		{{_, max_y}, _} = data_map |> Enum.max_by(fn {{_, y}, _} -> y end)
		{max_x, max_y} #|> IO.inspect(label: "Map Size")
	end

	@offsets  [          {0, -1},
		          {-1,  0},          {1,  0},
                    		{0,  1},            ]

	def possible_next_steps(data_map, {x,y}, {max_x, max_y}) do
		#{max_x, max_y} = get_size(data_map)

		Enum.map(@offsets, fn {xo, yo} -> {x + xo, y + yo} end)
		|> Enum.filter(fn {xp, yp} -> xp >= 0 and yp >= 0 and xp <= max_x and yp <= max_y end)
	end

end


defmodule Day15 do
	def split_str_to_tuple(s, pattern), do: String.split(s, pattern, trim: true) |> List.to_tuple()
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)
	def string_list_to_charlist_list(str_list) do
		str_list |> Enum.map(fn s -> to_charlist(s) end)
	end

	def move_cost(data_map, {from_x, from_y}, data_map_size) do
		fields = DataMap.possible_next_steps(data_map, {from_x, from_y}, data_map_size)
		|> Enum.map(fn {tx, ty} -> {{tx, ty}, data_map[{tx, ty}]} end)
	end


	# path is {cost, visited_fields}
	def extend_path(data_map, {path_cost, path_field, path_len}, cost_map, data_map_size) do

		# Possible next steps
		move_cost(data_map, path_field, data_map_size)
		|> Enum.filter(fn {target_pos, target_cost} ->

				# do we have already a cost for this field?
				cost_for_field = cost_map[target_pos]

				# if not keep it, else keep it only if cheaper
				cost_for_field == nil || (target_cost + path_cost) < cost_for_field
		 end)

		# Create a list of all the known paths
		|> Enum.map(fn {{tx, ty}, c} -> {path_cost + c, {tx, ty}, path_len + 1} end)
	end

	def merge_path_into_list(path_list, new_path) do
		{new_path_cost, new_path_field, new_path_len} = new_path

		path_hit = Enum.find(path_list, fn {_, visited_fields, _} ->
      new_path_field == visited_fields
		end)

		if path_hit == nil do
			# Path not known yet, add to list
			[new_path | path_list]
		else
			{existing_path_cost, _} = path_hit
			if new_path_cost < existing_path_cost do
				# New path is shorter, replace in list
				path_list = List.delete(path_list, path_hit)
				[new_path | path_list]
			else
				# New path is longer, ignore
				path_list
			end
		end
	end

	def distance({x1, y1}, {x2, y2}) do
		a = abs(x1 - x2)
		b = abs(y1 - y2)

		:math.sqrt(a*a*b*b)
	end

	def sort_path(paths, target) do
		sorted_path = Enum.sort(paths, fn {c1, pf1, l1}, {c2, pf2, l2} ->
			if c1 < c2 do
				true
			else
				if c1 > c2 do
					false
				else
					l1 < l2
				end
      end
		end)
	end

	def find_path(data_map, paths, cost_map, data_map_size) do

		#sorted_path = Enum.sort(paths, fn {c1, _}, {c2, _} -> c1 < c2 end)
		shorted_path = hd(paths)
		new_path = extend_path(data_map, shorted_path, cost_map, data_map_size) #|> IO.inspect(label: "Extend")

		# Update checked fields
		updated_cost_map = new_path |> Enum.map(fn {c, path_field, _} -> {path_field, c} end) |> Enum.into(cost_map) #|> IO.inspect(label: "Cost map")


		# Remove shortest path from path
		sorted_path = List.delete(paths, shorted_path)

		# merge new path into existing path
		{updated_cost_map, Enum.reduce(new_path, sorted_path, fn path, list -> merge_path_into_list(list, path) end )}
	end

	def find_path_rec(data_map, to, paths, interation, best, cost_map, data_map_size) do
		#interation |> IO.inspect(label: "interation")
		#hd(paths)|> IO.inspect(label: "best path")
	  {updated_cost_map, new_path} = find_path(data_map, paths, cost_map, data_map_size)

		# Are we there?
		sorted_path = sort_path(new_path, to)

		new_best = hd(sorted_path)
		best = if new_best != best do
			{best_cost, best_path, len} = new_best
			if rem(interation, 1000) == 0 do
				IO.puts("New best at iter #{interation} is #{best_cost} #{inspect(best_path)} with len #{len}")
			end
			new_best
    else
      best
    end

		#	Enum.sort(new_path, fn {c1, _}, {c2, _} -> c1 < c2 end)
		path_hit = Enum.find(sorted_path, fn {_, visited_field, _} -> visited_field == to end)

		if path_hit == nil do
			find_path_rec(data_map, to, sorted_path, interation + 1, best, updated_cost_map, data_map_size)
		else
			path_hit
		end
	end
end

input = File.stream!(filename) |> Enum.map(&String.trim/1) |> IO.inspect(label: "Input")
data_map = DataMap.create(input) |> IO.inspect(label: "Data Map")
{max_x, max_y} = DataMap.get_size(data_map) |> IO.inspect(label: "Map Size")

Day15.find_path_rec(data_map, {max_x, max_y}, [{0, {0,0}, 0}], 1, nil, Map.new(), {max_x, max_y}) |> IO.inspect(label: "Result Part 1")


#Day15.find_path_rec(data_map, {10, 10}, [{0, {0,0}, 0}], 1, nil, Map.new(), {max_x, max_y}) |> IO.inspect(label: "Result Part 1")




#import ExUnit.Assertions
#assert %{'NN' => 1} == Day15.polymerization_quick('NN', nil)
#assert %{'NN' => 2} == Day15.polymerization_quick('NNN', nil)
#assert %{'NN' => 1, 'NB' => 1} == Day15.polymerization_quick('NNB', nil)
#
