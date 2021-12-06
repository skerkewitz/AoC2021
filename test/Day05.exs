#filename = "input/day05-simple.txt"
filename = "input/day05-real.txt"

defmodule Day05 do
	def split_str_to_int(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)
	def sign(n) do if n > 0, do: 1, else: -1 end

	def gen_diagonal_coords_from_endpoints_part([x1, y1], [x2, y2]) do
		dx = abs(x1 - x2); dy = abs(y1 - y2)
		if dx == dy do # Is it diagonal?
			sx = sign(x1 - x2); sy = sign(y1 - y2)
			for d <- 0..dx, do: {x1 + (d * sx), y1 +(d * sy)} # Gen coords for diagonal
		else
			[]
		end
	end

	def gen_coords_from_endpoints_part([x1,y1], [x2,y2], is_part2?) do
		cond do
			x1 == x2 -> for y <- y1..y2, do: {x1, y} # Gen coords for horizontal line
			y1 == y2 -> for x <- x1..x2, do: {x, y1} # Gen coords for vertical line
			is_part2? -> gen_diagonal_coords_from_endpoints_part([x1, y1], [x2, y2]) # Possible diagonal line
			true -> [] # coords discard
		end
	end

	def gen_coords_from_str(s, is_part2?) do
		[p1, p2] = String.split(s, " -> ", trim: true) |> Enum.map(&(split_str_to_int(&1, ",")))
		gen_coords_from_endpoints_part(p1, p2, is_part2?)
	end

	def count_coords(input, is_part2?) do
		coords = input |> Enum.map(&(Day05.gen_coords_from_str(&1, is_part2?)))
		# Count coords which are used twice or more
		coords |> List.flatten() |> Enum.frequencies() |> Enum.filter(fn {{_, _}, n} -> n > 1 end) |> Enum.count()
	end
end

input = File.stream!(filename) |> Enum.map(&String.trim/1)
Day05.count_coords(input, false) |> IO.inspect(label: "Result 1")
Day05.count_coords(input, true) |> IO.inspect(label: "Result 2")
