#import ExUnit.Assertions

#filename = "input/day14-super-simple.txt"
#filename = "input/day14-simple.txt"
filename = "input/day14-real.txt"

defmodule Day14 do
	def split_str_to_tuple(s, pattern), do: String.split(s, pattern, trim: true) |> List.to_tuple()
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)
	def string_list_to_charlist_list(str_list) do
		str_list |> Enum.map(fn s -> to_charlist(s) end)
	end

	def scan_instructions_part1(instruction) do
		instruction #|> IO.inspect(label: "instruction in")
		|> Enum.map(fn s -> s |> String.split(" -> ", trim: true) |> string_list_to_charlist_list() |> List.to_tuple() end)
#		|> Enum.map(fn s -> s |> String.split("=", trim: true) |> List.to_tuple() end)
#		|> Enum.map(fn {i, v} -> {i, String.to_integer(v)} end)
#		#|> IO.inspect(label: "instruction out")
	end

	def scan_instructions_part2(instruction) do
		instruction #|> IO.inspect(label: "instruction in")
		|> Enum.map(fn s ->
      {k, v} = s |> String.split(" -> ", trim: true) |> string_list_to_charlist_list() |> List.to_tuple()
			#{k, [hd(k)] ++ v ++ tl(k) }
			{k, [hd(k)] ++ v }
		end)
		#		|> Enum.map(fn s -> s |> String.split("=", trim: true) |> List.to_tuple() end)
		#		|> Enum.map(fn {i, v} -> {i, String.to_integer(v)} end)
		#		#|> IO.inspect(label: "instruction out")
	end

	def insert_if_needed(pair, _, cache, count, max_count) when count == 0, do: {cache, pair}
	def insert_if_needed(pair, pair_insertion, cache, count, max_count) do

		IO.puts("#{inspect{pair, count}}")

		# Check cache first
		cached = cache[{pair, count}]
		if cached != nil do
			#IO.puts("Cache hit for #{inspect{pair, count}}")
			{cache, cached}
		else
			# No Cache hit
			#IO.puts("No hit for #{inspect{pair, count}}")
			pair_match = pair_insertion[pair] #|> Enum.filter(fn {s, i} -> s == pair end) |> List.first()

			if pair_match == nil do
				# There is no insert rule, just let is pass
				#IO.puts("Add pair #{inspect{pair, count}} to cache")
				cache = Map.put(cache, {pair, count}, pair)
				{cache, pair}
			else
				# There is a insert rule.
				[l, r] = pair

				# Create a new part CH -> CBH
				left_part = [l] ++ pair_match ++ [r] #|> IO.inspect(label: "Left part")
        #{cache, poly_left} = polymerization_part1(left_part, pair_insertion, cache, count - 1, max_count)
				#poly_left |> IO.inspect(label: "Poly left")

				# Is there a rule for BH?
				#right_part = tl(poly_left) ++ [r]

				# We don't need the railing H
				#poly_right = insert_if_needed(right_part, pair_insertion, max_count - 1)
				#poly_right |> IO.inspect(label: "Poly Right")
				#full = (poly_left ++ poly_right) |> IO.inspect(label: "Full resolved for #{inspect(pair)}")
				#Enum.take(full, length(full) -1) |> IO.inspect(label: "Return for #{inspect(pair)}")
				if count < 15 do
					{cache, poly_left} = polymerization_part1(left_part, pair_insertion, cache, count - 1, max_count)
					#IO.puts("Add computation to #{inspect{pair, count}} #{poly_left} to cache #{inspect(cache)}")
					cache = Map.put(cache, {pair, count}, poly_left)
					#|> Map.delete({pair, count-1})
					#polymerization_part1(left_part, pair_insertion, cache, count - 1, max_count)
					{cache, poly_left}
				else
					polymerization_part1(left_part, pair_insertion, cache, count - 1, max_count)
				end
			end
		end
	end


	def polymerization_part1(template, _, cache, count, max_count) when count == 0, do: {cache, template}
	def polymerization_part1(template, pair_insertion, cache, count, max_count) do
		#IO.puts("polymerization_part1 with template  #{inspect(template)} and count #{max_count}")
	{ca, new_template} = template
		               |> Enum.chunk_every(2, 1, :discard)
									 |> List.foldl({cache, ''}, fn e, {c, a} ->
			if count == max_count do
				#IO.puts("#{e} cache #{inspect(c)}")
				IO.puts("#{e}")
			end
      {cache_new, l} = insert_if_needed(e, pair_insertion, c, count, max_count)
			l = Enum.take(l, length(l) -1)
			{cache_new, a ++ l}
		end)
	{ca, new_template ++ [List.last(template)]}
	end


	def polymerization_quick(template, pair_insertion) do
		#IO.puts("polymerization_part1 with template  #{inspect(template)} and count #{max_count}")
		template
		|> Enum.chunk_every(2, 1, :discard)
		|> Enum.frequencies()
	end

	def quick_expand(map, pair_insertion) do
		map |> Enum.map(fn {pair, count} ->
			insert = pair_insertion[pair]
			if insert == nil do
				%{pair => count}
			else
				[l, r] = pair

        #(insert ++ tl(pair)) |> IO.inspect(label: "R is list #{is_list('' ++ List.last(pair))}")# , charlists: :as_lists)
				%{[l | insert] => count, (insert ++ tl(pair)) => count}
			end
		end)
		#|> List.flatten()
		#|> Enum.frequencies()
	end



	def rec_expand(map, pair_insertion, count) when count == 0, do: map
	def rec_expand(map, pair_insertion, count) do
		quick_expand(map, pair_insertion) |> Enum.reduce(%{}, fn e, a -> Map.merge(e, a, fn _k, v1, v2 -> v1 + v2 end) end)
		|> rec_expand(pair_insertion, count - 1)
	end

	def polymerization_new(template, pair_insertion, count) do
		polymerization_quick(template, pair_insertion)
		|> rec_expand(pair_insertion, count) #|> IO.inspect(label: "Quick 1")

	end


	def template_begins_with_lookup_key?(template, key) do
		search = elem(Enum.split(template, length(key)), 0) #|> IO.inspect(label: "Search");
		search == key
	end

#	def polymerization_part2(template, lookup_table) when template == '', do: ''
#	def polymerization_part2(template, lookup_table) do
#		#IO.puts("polymerization_part2 with template  #{inspect(template)}")
#		lookup_keys = Map.keys(lookup_table) |> Enum.sort(&(length(&1) > length(&2))) # |> IO.inspect(label: "Sortet looup")
#		lookup_key = lookup_keys |> Enum.find(fn k -> template_begins_with_lookup_key?(template, k) end)
#
#		if lookup_key == nil do
#			{l, r} = Enum.split(template, 2) #|> IO.inspect(label: "No hit, let pass")
#			l ++ polymerization_part2(r, lookup_table)
#		else
#			pair_match = lookup_table[lookup_key] #|> Enum.filter(fn {s, i} -> s == pair end) |> List.first()
#			{l, r} = Enum.split(template, length(lookup_key) - 1) #|> IO.inspect(label: "Hit in lookuptable for #{lookup_key} = #{pair_match}, split in replace and remaining")
#			pair_match ++ polymerization_part2(r, lookup_table)
#		end
#	end

	def polymerization_rec(template, _, max_count) when max_count == 0, do: template
	def polymerization_rec(template, pair_insertion, max_count) do
		#IO.puts("Iterations to go #{max_count}")
		#new_template = polymerization_part1(template, pair_insertion, max_count)
#		polymerization_part1(template, pair_insertion, max_count)
		#polymerization_rec(new_template, pair_insertion, max_count-1)
	end

#	def extend_instruction(template, instruction) do
#		extended = template
#		           |> to_charlist()
#		           |> Enum.uniq()
#		           |> IO.inspect(label: "unique inputs")
#		           |> to_charlist()
#		           |> Enum.map(fn c -> Enum.map(instruction, fn {k, v} -> k = k ++ [c]; {k, Day14.polymerization_part2(k, instruction)} end) end)
#		           |> List.flatten()
#		           |> Enum.map(fn {k, v} -> {k, Enum.take(v, length(v) -1)} end)
#		           |> IO.inspect(label: "extended instructions")
#		Enum.into(extended, instruction) |> IO.inspect(label: "extended instructions")
#	end

	def expand(input, instructions) do
		[h, t] = input
	end


end





{template, instruction} = File.stream!(filename) |> Enum.map(&String.trim/1) |> Enum.join("\n") |> String.split("\n\n", trim: true) |> List.to_tuple()
template |> String.split("\n", trim: true) |> to_charlist() |> IO.inspect(label: "template")
instruction = instruction |> String.split("\n", trim: true) |> Day14.scan_instructions_part1() |> Enum.into(%{})|> IO.inspect(label: "instruction")

#extended = template
#|> to_charlist()
#|> Enum.uniq()
#|> IO.inspect(label: "unique inputs")
#|> to_charlist()
#|> Enum.map(fn c -> Enum.map(instruction, fn {k, v} -> k = k ++ [c]; {k, Day14.polymerization_part2(k, instruction)} end) end)
#|> List.flatten()
#|> Enum.map(fn {k, v} -> {k, Enum.take(v, length(v) -1)} end)
#|> IO.inspect(label: "extended instructions")
#extended_instruction = Enum.into(extended, instruction) |> IO.inspect(label: "extended instructions")

#extended_instruction = Day14.extend_instruction(template, instruction)
extended_instruction = instruction
#extended_instruction = Day14.extend_instruction(template, extended_instruction)
#extended_instruction = Day14.extend_instruction(template, extended_instruction)
#extended_instruction = Day14.extend_instruction(template, extended_instruction)
#extended_instruction = Day14.extend_instruction(template, extended_instruction)
#extended_instruction = Day14.extend_instruction(template, extended_instruction)
#extended_instruction = Day14.extend_instruction(template, extended_instruction)

#|> Enum.reduce(instruction, fn e, acc ->
#	acc ++ insert_pair_instruction_if_needed(e, pair_insertion) end)

## Part 1
#{_, poly} = Day14.polymerization_part1(to_charlist(template), extended_instruction, %{}, 30, 30) #|> IO.inspect(label: "Result")
#poly |> length() |> IO.inspect(label: "Len")
#histogram = poly
#|> Enum.frequencies()
#|> Map.to_list()
#|> IO.inspect(label: "Histogram")
##
##
#max = Enum.max_by(histogram, fn {_, v} -> v end) |> IO.inspect(label: "Max")
#min = Enum.min_by(histogram, fn {_, v} -> v end) |> IO.inspect(label: "Min")
##
#elem(max, 1) - elem(min, 1) |> IO.inspect(label: "Result Part 1")


#map_data = template |> DataMap.create() #|> DataMap.print()
#Day14.polymerization(template, instruction) |> IO.inspect(label: "Result Part 1")

#Day14.fold_with_instruction(map_data, hd(instruction)) |> Map.size()|> IO.inspect(label: "Result Part 1")
#Day14.fold(map_data, instruction) |> DataMap.print() # Prints result Part 2

#Day14.fold(map_data, instruction, 1)

#|>Enum.map(fn e -> [e, create_revert_edges(e)] end)
#|> List.flatten()


#graph = Day14.create_graph_from_file(filename)
#Day14.find_path(graph, "start", "end", [], [], 1) |> Enum.count() |> IO.inspect(label: "Part 1")
#Day14.find_path(graph, "start", "end", [], [], 2) |> Enum.count() |> IO.inspect(label: "Part 2")

import ExUnit.Assertions
#assert %{'NN' => 1} == Day14.polymerization_quick('NN', nil)
#assert %{'NN' => 2} == Day14.polymerization_quick('NNN', nil)
#assert %{'NN' => 1, 'NB' => 1} == Day14.polymerization_quick('NNB', nil)
#
#assert [%{'CN' => 1, 'NC' => 1}] == Day14.quick_expand(%{'NN' => 1}, instruction)
#
#assert Enum.chunk_every('NCNBCHB', 2, 1, :discard) |> Enum.frequencies() |> Enum.sort() == Day14.polymerization_new('NNCB', instruction, 1) |> Enum.sort()
#assert Enum.chunk_every('NBCCNBBBCBHCB', 2, 1, :discard) |> Enum.frequencies() |> Enum.sort() == Day14.polymerization_new('NNCB', instruction, 2) |> Enum.sort()
#assert Enum.chunk_every('NBBBCNCCNBBNBNBBCHBHHBCHB', 2, 1, :discard) |> Enum.frequencies() |> Enum.sort() == Day14.polymerization_new('NNCB', instruction, 3) |> Enum.sort()
#
#Enum.frequencies('NBBBCNCCNBBNBNBBCHBHHBCHB') |> IO.inspect()
#Day14.polymerization_new('NNCB', instruction, 3) |> Enum.map(fn {k, v} -> %{hd(k) => v} end) |> Enum.reduce(%{}, fn e, a -> Map.merge(e, a, fn _k, v1, v2 -> v1 + v2 end) end) |> Enum.sort() |> IO.inspect()
#
#
#Enum.frequencies('NCNBCHB') |> IO.inspect()
h = Day14.polymerization_new(to_charlist(template), instruction, 40) |> Enum.map(fn {k, v} -> %{hd(k) => v} end) |> Enum.reduce(%{}, fn e, a -> Map.merge(e, a, fn _k, v1, v2 -> v1 + v2 end) end)
|> Enum.map(fn {k, v} -> v end)
|> Enum.sort()
|> IO.inspect()

min = hd(h)
max = List.last(h)

max - min |> IO.inspect(label: "Result Part 2")



#import ExUnit.Assertions
#assert 'NCN' == Day14.insert_if_needed('NN', instruction, 1)
#assert 'NBC' == Day14.insert_if_needed('NC', instruction, 1)
#assert 'CHB' == Day14.insert_if_needed('CB', instruction, 1)
#
##assert 'NBBBC' == Day14.insert_if_needed('NBC', instruction, 1)
##assert 'NBBBC' == Day14.insert_if_needed('NN', instruction, 2)
#
#
#assert 'NCN' == Day14.insert_if_needed('NN', instruction, 1)
#assert 'NCNBCHB' == Day14.polymerization_part1('NNCB', extended_instruction, 1)
#assert 'NBCCNBBBCBHCB' == Day14.polymerization_part1('NNCB', extended_instruction, 2)
#
#
#assert 'NCN' == Day14.polymerization_part1('NN', instruction, 1)
#assert 'NBCCN' == Day14.polymerization_part1('NCN', instruction, 1)
#
#assert 'NBCCN' == Day14.insert_if_needed('NN', instruction, 2)
#
##assert 'NBCCC' == Day14.insert_if_needed('NN', instruction, 2)  #NN -> NC + N => NC CN -> NB + C, CCN


#NN = NCN
#NCN = NBCCCN

#assert 'AA' == Day14.insert_pair_instruction_if_needed('AA', instruction)

#assert 'NCNBCHB' == Day14.polymerization_rec('NNCB', extended_instruction, 1)
#assert 'NBCCNBBBCBHCB' == Day14.polymerization_rec('NNCB', extended_instruction, 2)



#assert 'AA' == Day14.polymerization_part2('AA', instruction)
#assert 'NCN' == Day14.polymerization_part2('NN', instruction)
#assert 'NCNBCHB' == Day14.polymerization_part2('NNCB', instruction)
#assert 'NCNBC' == Day14.polymerization_part2('NNC', instruction)
#
#assert 'NCNBCHB' == Day14.polymerization_rec('NNCB', instruction, 1)
#assert 'NBCCNBBBCBHCB' == Day14.polymerization_rec('NNCB', instruction, 2)
#assert 'NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB' == Day14.polymerization_rec('NNCB', instruction, 4)


#assert true == Day14.can_visit_connection("A", ["start"], 1)


#assert false == Day14.can_visit_connection("A", ["start", "A"], 1)
#assert true == Day14.can_visit_connection("A", ["start", "A"], 2)
#
#assert {1, [{"A", "c"}, {"A", "b"}, {"A", "end"}]} == Day14.find_connections(graph, "A", [], 1)
#
#assert {2, [{"A", "c"}, {"A", "b"}, {"A", "end"}]} == Day14.find_connections(graph, "A", ["c"], 2) # c is still allowed because first time we would visit twice
#assert {1, [{"A", "b"}, {"A", "end"}]} == Day14.find_connections(graph, "A", ["c", "f", "f"], 2) #  c is not allowed because we already visited f twice

#assert [{0,7}, {0, 6}] == DataMap.fold_coords_horizontal([{0, 7}, {0, 8}], 7)
