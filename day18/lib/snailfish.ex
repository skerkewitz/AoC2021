defmodule Snailfish do
	@moduledoc false


  def find_opening_bracket(chars, _, _) when length(chars) == 0, do: {:not_found}
  def find_opening_bracket(chars, bracket_depth, pos) do
    head = hd(chars)

    if head == ?[ do
      new_bracket_depth = bracket_depth - 1
      if new_bracket_depth == 0 do
        {:found, pos}
      else
        find_opening_bracket(tl(chars), new_bracket_depth, pos + 1)
      end
    else
      new_bracket_depth = if head == ?], do: bracket_depth + 1, else: bracket_depth
      find_opening_bracket(tl(chars), new_bracket_depth, pos + 1)
    end
  end

  def needs_explosion(str) do
    case find_opening_bracket(to_charlist(str), 5, 0) do
      {:not_found} -> false
      {:found, _} -> true
    end
  end

  def go_until(chars, pos, _, _) when pos > length(chars) or pos < 0, do: {:not_found}
  def go_until(chars, pos, direction, condition_fun) do
    if condition_fun.(Enum.at(chars, pos)) do
      {:found, pos}
    else
      go_until(chars, pos + direction, direction, condition_fun)
    end
  end

  def is_digit(c) when c == nil, do: false
  def is_digit(c) when is_integer(c) do
    (c >= ?0 and c <= ?9)
  end

  def find_number(chars, pos, direction) do
    case go_until(chars, pos, direction, &(is_digit(&1))) do
      {:not_found} -> {:not_found}
      {:found, start_pos } ->
        case go_until(chars, start_pos, direction, &(!is_digit(&1))) do
          {:not_found} -> {:not_found}
          {:found, end_pos } ->
            # We need the position before end pos, that the last time the condition was true
            end_pos = end_pos - direction
            # Make sure start position < end position
            {:found, {min(start_pos, end_pos), max(start_pos, end_pos)}}
        end
    end
  end

  def parse_number(chars, pos, direction) do
    case find_number(chars, pos, direction) do
      {:not_found} -> {:not_found}
      {:found, {start_pos, end_pos} } ->
          chars = Enum.drop(chars, start_pos)
          chars = Enum.take(chars, (end_pos - start_pos) + 1)
          i = String.to_integer(to_string(chars))
          {:found, i, {start_pos, end_pos}}
    end
  end

  def find_exploding_pair(chars) do
    # Find opening bracket of exploding pair
    case Snailfish.find_opening_bracket(chars, 5, 0) do
      {:not_found} -> {:not_found}
      {:found, opening_bracket} ->
        # Parse the number in the pair
        {:found, n1, {ns1, ne1}} = Snailfish.parse_number(chars, opening_bracket + 1, 1)
        {:found, n2, {ns2, ne2}} = Snailfish.parse_number(chars, ne1 + 1, 1)
        {:found, {n1, n2}, {opening_bracket, ne2 + 1}}
    end
  end

  def do_explosion_part(chars, n, parse_number_result) do
    case parse_number_result do
      {:not_found} -> chars
      {:found, i, {start_pos, end_pos}} ->
        left = Enum.take(chars, start_pos)

        # Handle right
        right = Enum.drop(chars, end_pos + 1)

        new_number = n + i
        cl = Integer.to_char_list(new_number)

        left ++ cl ++ right
    end
  end

  def do_explosion_left(chars, n) do
    #chars |> IO.inspect(label: "Left")
    do_explosion_part(chars, n, parse_number(chars, length(chars), -1))
  end

  def do_explosion_right(chars, n) do
    #chars |> IO.inspect(label: "Right")
    do_explosion_part(chars, n, parse_number(chars, 0, 1))
  end


  def do_explosion(chars) do
    # Find opening bracket of exploding pair
    case Snailfish.find_exploding_pair(chars) do
      {:not_found} -> {false, chars}
      {:found, {n1, n2}, {s, e}} ->
        # Handle left
        left_chars = Enum.take(chars, s)
        left = do_explosion_left(left_chars, n1)

        # Handle right
        rights_chars = Enum.drop(chars, e + 1)
        right = do_explosion_right(rights_chars, n2)

        {true, left ++ '0' ++ right}
    end
  end

  def find_split_number(chars, start_pos \\ 0) do
    # Find opening bracket of exploding pair
    case Snailfish.parse_number(chars, start_pos, 1) do
      {:not_found} -> {:not_found}
      {:found, i, {start_pos, end_pos}} ->
        # Is number to big?
        if i > 9 do
          {:found, i, {start_pos, end_pos}} # yes, return it
        else
          find_split_number(chars, end_pos + 1) # no, search next
        end
    end
  end

  def do_split(chars) do
    case Snailfish.find_split_number(chars) do
      {:not_found} -> {false, chars}
      {:found, i, {start_pos, end_pos}} ->
        # Handle left
        left = Enum.take(chars, start_pos)

        # Handle right
        right = Enum.drop(chars, end_pos + 1)

        l = floor(i / 2.0)
        r = ceil(i / 2.0)
        m = to_charlist("[#{l},#{r}]")

        {true, left ++ m ++ right}
    end
  end

  def do_split_rec(chars) do
    case do_split(chars) do
      {false, _ } -> chars
      {true, chars} -> do_explode_and_split(chars)
    end
  end

  def do_explode_and_split(chars) do
    case do_explosion(chars) do
      {false, _ } -> do_split_rec(chars)
      {true, chars} -> do_explode_and_split(chars)
    end
  end

  def add(s1, s2) do
    added = "[#{s1},#{s2}]"
    to_string(do_explode_and_split(to_charlist(added)))
  end

  def reduce(l) do
    acc = hd(l)
    tl(l) |> Enum.reduce(acc, fn e, a -> add(a, e) end)
  end

  def magnitude_of_pair(chars) do

    # Make sure this is a pair start
    h = hd(chars)
    if h != ?[, do: raise "Not a pair start"

    t = tl(chars)

    # We expect either a number of a pair
    {left, chars} = if Enum.at(t, 0) == ?[ do
       magnitude_of_pair(t)
    else
      {:found, i, {_, end_pos}} = parse_number(t, 0, 1)
      {i, Enum.drop(t, end_pos + 1)}
    end

    #left |> IO.inspect(label: "Left")

    # Skip ,
    chars = Enum.drop(chars, 1)

    # We expect either a number of a pair
    {right, chars} = if Enum.at(chars, 0) == ?[ do
      magnitude_of_pair(chars)
    else
      {:found, i, {_, end_pos}} = parse_number(chars, 0, 1)
      {i, Enum.drop(chars, end_pos + 1)}
    end

    #right |> IO.inspect(label: "Right")

    h = hd(chars)
    if h != ?], do: raise "Did exspect pair end"
    t = tl(chars)

    {(left * 3) + (right * 2), t}
  end


end
