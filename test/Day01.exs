import ExUnit.Assertions

#filename = "input/day01-simple.txt"
filename = "input/day01-real.txt"

{:ok, contents} = File.read(filename)
lines = contents
        |> String.split("\n", trim: true)
        |> map(&String.to_integer/1)



# First part
count = lines
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.count(fn [a, b] -> a < b end)

IO.puts("Result is #{inspect(count)}")
assert 1715 == count

# Second part
count = lines
        |> Enum.chunk_every(3, 1, :discard)
        |> Enum.map(&Enum.sum/1)
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.count(fn [a, b] -> a < b end)

IO.puts("Result is #{inspect(count)}")
assert 1739 == count



