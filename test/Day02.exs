import ExUnit.Assertions

#filename = "input/day02-simple.txt"
filename = "input/day02-real.txt"

input = File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Enum.map(&(String.split(&1, " ", trim: true)))
        |> Enum.map(fn [a, b] -> [a, String.to_integer(b)] end)

## First part
input
|> Enum.reduce(
	   {0, 0},
	   fn c, {h, d} ->
		   case c do
			   ["forward", v] -> {h + v, d}
			   ["down", v] -> {h, d + v}
			   ["up", v] -> {h, d - v}
		   end
	   end
   )
|> (fn {h, d} -> h * d end).()
|> IO.inspect(lable: "Result 1")

# Second part
input
|> Enum.reduce(
	   {0, 0, 0},
	   fn c, {h, d, a} ->
		   case c do
			   ["forward", x] -> {h + x, d + (a * x), a}
			   ["down", x] -> {h, d, a + x}
			   ["up", x] -> {h, d, a - x}
		   end
	   end
   )
|> IO.inspect(lable: "Result 1")

IO.puts("Result is #{inspect(count)}")
#assert 1739 == count



