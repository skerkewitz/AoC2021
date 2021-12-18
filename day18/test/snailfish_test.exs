defmodule SnailfishTest do
  use ExUnit.Case
  doctest Snailfish

#  test "find opening bracket" do
#    assert {:not_found} == Snailfish.find_opening_bracket(to_charlist(""), 5, 0)
#
#    assert {:found, 0} == Snailfish.find_opening_bracket(to_charlist("[1,2]"), 1, 0)
#    assert {:found, 6} == Snailfish.find_opening_bracket(to_charlist("[1,[2,[3,4]]]"), 3, 0)
#
#    assert {:not_found} == Snailfish.find_opening_bracket(to_charlist("[1,[2,[3,4]]]"), 4, 0)
#  end
#
#  test "test needs explosion" do
#    assert true == Snailfish.needs_explosion("[[[[[9,8],1],2],3],4]")
#    assert true == Snailfish.needs_explosion("[7,[6,[5,[4,[3,2]]]]]")
#    assert true == Snailfish.needs_explosion("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
#  end
#
#  test "test go while" do
#    # Test go right
#    assert {:found, 0} == Snailfish.go_until('0123456', 0, 1, fn c -> c == ?0 end)
#    assert {:found, 6} == Snailfish.go_until('0123456', 0, 1, fn c -> c == ?6 end)
#    assert {:not_found} == Snailfish.go_until('0123456', 0, 1, fn c -> c == ?7 end)
#
#    # Test go left
#    assert {:found, 0} == Snailfish.go_until('0123456', 6, -1, fn c -> c == ?0 end)
#    assert {:found, 6} == Snailfish.go_until('0123456', 6, -1, fn c -> c == ?6 end)
#    assert {:not_found} == Snailfish.go_until('0123456', 6, -1, fn c -> c == ?7 end)
#  end
#
#  test "is_digit" do
#    assert true == Snailfish.is_digit(?0)
#    assert true == Snailfish.is_digit(?2)
#    assert true == Snailfish.is_digit(?9)
#
#    assert false == Snailfish.is_digit(?a)
#  end

  test "find number" do
    assert {:found, {3, 5}} == Snailfish.find_number('abc123h', 0, 1)
    assert {:found, {3, 5}} == Snailfish.find_number('abc123', 0, 1)

    assert {:found, {3, 5}} == Snailfish.find_number('abc123h', 7, -1)
  end

  test "parse number" do
    assert {:found, 123, {3, 5}} == Snailfish.parse_number('abc123h', 0, 1)
    assert {:found, 123, {3, 5}} == Snailfish.parse_number('abc123', 0, 1)

    assert {:found, 123, {3, 5}} == Snailfish.parse_number('abc123h', 7, -1)
  end

  test "find_exploding_pair" do

    assert {:found, {9, 8}, {4, 8}} == Snailfish.find_exploding_pair('[[[[[9,8],1],2],3],4]')
    assert {:found, {3, 2}, {12, 16}} == Snailfish.find_exploding_pair('[7,[6,[5,[4,[3,2]]]]]')
    assert {:found, {3, 2}, {24, 28}} == Snailfish.find_exploding_pair('[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]')

    assert {:found, {31, 23}, {24, 30}} == Snailfish.find_exploding_pair('[[3,[2,[8,0]]],[9,[5,[4,[31,23]]]]]')
  end

  test "do_exploding" do
    assert {true, '[[[[0,9],2],3],4]'} == Snailfish.do_explosion('[[[[[9,8],1],2],3],4]')
    assert {true, '[7,[6,[5,[7,0]]]]'} == Snailfish.do_explosion('[7,[6,[5,[4,[3,2]]]]]')
    assert {true, '[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]'} == Snailfish.do_explosion('[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]')
    assert {true, '[[3,[2,[8,0]]],[9,[5,[7,0]]]]'} == Snailfish.do_explosion('[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]')
  end

  test "find_split_number" do
    assert {:found, 15, {13, 14}} == Snailfish.find_split_number('[[[[0,7],4],[15,[0,13]]],[1,1]]')
    assert {:found, 13, {22, 23}} == Snailfish.find_split_number('[[[[0,7],4],[[7,8],[0,13]]],[1,1]]')
  end

  test "do_split" do
    assert {true, '[[[[0,7],4],[[7,8],[0,13]]],[1,1]]'} == Snailfish.do_split('[[[[0,7],4],[15,[0,13]]],[1,1]]')
    assert {true, '[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]'} == Snailfish.do_split('[[[[0,7],4],[[7,8],[0,13]]],[1,1]]')
  end

  test "do_explode_and_split" do
    assert '[[[[0,7],4],[[7,8],[6,0]]],[8,1]]' == Snailfish.do_explode_and_split('[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]')
  end

  test "add" do
    assert "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]" == Snailfish.add("[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]")
  end

  test "reduce" do
    assert "[[[[1,1],[2,2]],[3,3]],[4,4]]" == Snailfish.reduce(["[1,1]", "[2,2]", "[3,3]", "[4,4]"])

    assert "[[[[5,0],[7,4]],[5,5]],[6,6]]" == Snailfish.reduce(["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]", "[6,6]"])
  end

  test "magnitute" do
    assert {29, []} == Snailfish.magnitude_of_pair('[9,1]')
    assert {143, []} == Snailfish.magnitude_of_pair('[[1,2],[[3,4],5]]')
    assert {1384, []} == Snailfish.magnitude_of_pair('[[[[0,7],4],[[7,8],[6,0]]],[8,1]]')
  end

  test "Simple Test 1" do
    filename = "input/day18-super-simple.txt"
    #filename = "input/day18-simple.txt"
    #filename = "input/day18-real.txt"

    input = File.stream!(filename) |> Enum.map(&String.trim/1)
    result = Snailfish.reduce(input)
    assert "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]" == result

    filename = "input/day18-super-simple2.txt"

    input = File.stream!(filename) |> Enum.map(&String.trim/1)
    result = Snailfish.reduce(input)
    assert "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]" == result
    assert {4140, []} == Snailfish.magnitude_of_pair(to_charlist(result))



  end

  test "Part 1" do
    filename = "input/day18-real.txt"

    input = File.stream!(filename) |> Enum.map(&String.trim/1)
    result = Snailfish.reduce(input)
    #assert "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]" == result
    assert {4365, []} == Snailfish.magnitude_of_pair(to_charlist(result))

  end

  test "Part 2 Simple test" do
    filename = "input/day18-super-simple2.txt"

    input = File.stream!(filename) |> Enum.map(&String.trim/1)

    result =
    for i <- 0..length(input) - 1 do
      master = Enum.at(input, i) #|> IO.inspect(label: "Master")
      List.delete_at(input, i) |> Enum.map(fn e ->
        #IO.puts("Will add #{master} and #{e}")
        added = Snailfish.add(master, e)
       {m, []} = Snailfish.magnitude_of_pair(to_charlist(added))
       m
      end)
    end
    |> List.flatten()
    |> Enum.max()

    assert 3993 == result

  end

  test "Part 2" do
    filename = "input/day18-real.txt"

    input = File.stream!(filename) |> Enum.map(&String.trim/1)

    result =
      for i <- 0..length(input) - 1 do
        master = Enum.at(input, i) #|> IO.inspect(label: "Master")
        List.delete_at(input, i) |> Enum.map(fn e ->
          #IO.puts("Will add #{master} and #{e}")
          added = Snailfish.add(master, e)
          {m, []} = Snailfish.magnitude_of_pair(to_charlist(added))
          m
        end)
      end
      |> List.flatten()
      |> Enum.max()

    assert 4490 == result

  end
end
