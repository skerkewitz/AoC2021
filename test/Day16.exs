#import ExUnit.Assertions

#filename = "input/day15-real-simple.txt"
#filename = "input/day15-simple.txt"
filename = "input/day15-real.txt"

defmodule Util do
	def split_str_to_tuple(s, pattern), do: String.split(s, pattern, trim: true) |> List.to_tuple()
	def split_str_to_ints(s, pattern), do: String.split(s, pattern, trim: true) |> Enum.map(&String.to_integer/1)
	def string_list_to_charlist_list(str_list) do
		str_list |> Enum.map(fn s -> to_charlist(s) end)
	end

end

defmodule Decoder do

	defstruct stream: [], read_count: 0

	# takes a string and return a list of bits
	def create(str) do

		stream = str
		|> String.split("", trim: true)
		|> Enum.map(fn s -> s |> String.to_integer(16) |> Integer.to_string(2) |> String.pad_leading(4, "0") |> Util.split_str_to_ints("") end)
		|> List.flatten()

#		stream = String.to_integer(str, 16) |> Integer.to_string(2) |> String.pad_leading(4) |> Util.split_str_to_ints("")
		%Decoder{stream: stream}
	end

	defp skip(decoder, amount) do
		new_stream = Enum.drop(decoder.stream, amount)
		new_decoder_read_count = decoder.read_count + amount
		%Decoder{stream: new_stream, read_count: new_decoder_read_count}
	end

	defp sub_stream_decoder(decoder, amount) do
		new_stream = Enum.take(decoder.stream, amount)
		new_decoder_read_count = 0
		%Decoder{stream: new_stream, read_count: new_decoder_read_count}
	end

	def move_head_to_next_packet_start(decoder) do
		skip = 4 - rem(decoder.read_count, 4) |> IO.inspect(label: "skip")
		skip(decoder, skip)
	end

	def read_bits(decoder, bits) do
		bit_lit = Enum.take(decoder.stream, bits)
#    new_stream = Enum.drop(decoder.stream, bits)
#    new_decoder_read_count = decoder.read_count + bits
#    new_decoder = %Decoder{stream: new_stream, read_count: new_decoder_read_count}
		{bit_lit, skip(decoder, bits)}
	end

	def read_bits_as_int(decoder, bits) do
		{bit_list, new_decoder} = read_bits(decoder, bits)
		{Integer.undigits(bit_list, 2), new_decoder}
	end

	def read_version(decoder) do
		read_bits_as_int(decoder, 3)
	end

	def read_type_id(decoder) do
		read_bits_as_int(decoder, 3)
	end

	defp read_literal_part(decoder) do
		{[has_more_in_group | data], new_decoder} = read_bits(decoder, 5)
		{{has_more_in_group == 1, data}, new_decoder}
	end

	defp read_literal_rec(decoder) do
		{{has_more_in_group, data}, new_decoder} = read_literal_part(decoder)
		if has_more_in_group do
			{data_list, new_decoder} = read_literal_rec(new_decoder)
			{[data | data_list], new_decoder}
		else
			{[data], new_decoder}
		end
	end

	def read_literal(decoder) do
		{data, new_decoder} = read_literal_rec(decoder)
		literal = data |> List.flatten() |> Integer.undigits(2)
		{literal, new_decoder}
	end

	def read_operator_sub_packet_length(decoder) do
		{length_type_bit, new_decoder} = read_bits_as_int(decoder, 1)

		if length_type_bit == 0 do
			{sub_packets_length_in_bits, new_decoder} = read_bits_as_int(new_decoder, 15)
			{{:sub_packet_length_in_bits, sub_packets_length_in_bits}, new_decoder}
		else
			{sub_packets_count, new_decoder} = read_bits_as_int(new_decoder, 11)
			{{:sub_packets_count, sub_packets_count}, new_decoder}
		end

	end

	def read_packet(decoder) do
		{version, decoder} = Decoder.read_version(decoder)
		{type, decoder} = Decoder.read_type_id(decoder)

		{literal, decoder} = Decoder.read_literal(decoder)

		{{version, type, literal}, decoder}
	end


	def read_sub_packets_by_bit_length(decoder, bit_length) do

		sub_decoder = sub_stream_decoder(decoder, bit_length)
		{packet1, sub_decoder} = read_packet(sub_decoder)
		{packet2, sub_decoder} = read_packet(sub_decoder)

		next_decoder = move_head_to_next_packet_start(skip(decoder, bit_length))
		{[packet1, packet2], next_decoder}
	end


	def read_sub_packets(decoder) do

	end

end

defmodule Day16 do


end

#input = File.stream!(filename) |> Enum.map(&String.trim/1) |> IO.inspect(label: "Input")

#decoder = Decoder.create("D2FE28") |> IO.inspect(label: "Result Part 1")
#
#{_, decoder} = Decoder.read_version(decoder) |> IO.inspect(label: "Version")
#{_, decoder} = Decoder.read_type_id(decoder) |> IO.inspect(label: "Type Id")
#
##{_, decoder} = Decoder.read_literal_part(decoder) |> IO.inspect(label: "Literal Part 1")
##{_, decoder} = Decoder.read_literal_part(decoder) |> IO.inspect(label: "Literal Part 2")
##{_, decoder} = Decoder.read_literal_part(decoder) |> IO.inspect(label: "Literal Part 3")
#
#{_, decoder} = Decoder.read_literal(decoder) |> IO.inspect(label: "Literal 1")

decoder = Decoder.create("38006F45291200") |> IO.inspect(label: "Result Part 1")
{_, decoder} = Decoder.read_version(decoder) |> IO.inspect(label: "Version")
{_, decoder} = Decoder.read_type_id(decoder) |> IO.inspect(label: "Type Id")

{{:sub_packet_length_in_bits, sub_packets_length_in_bits}, decoder} = Decoder.read_operator_sub_packet_length(decoder) |> IO.inspect(label: "Packet length")
{_, decoder} = Decoder.read_sub_packets_by_bit_length(decoder, sub_packets_length_in_bits) |> IO.inspect(label: "Packet length")




#import ExUnit.Assertions
#assert %{'NN' => 1} == Day15.polymerization_quick('NN', nil)
#assert %{'NN' => 2} == Day15.polymerization_quick('NNN', nil)
#assert %{'NN' => 1, 'NB' => 1} == Day15.polymerization_quick('NNB', nil)
#
