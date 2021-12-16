#import ExUnit.Assertions

#filename = "input/day15-real-simple.txt"
#filename = "input/day15-simple.txt"
filename = "input/day16-real.txt"

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

	def read_bits(decoder, bits) do

		if bits > length(decoder.stream) do
			raise "Stream not enough data"
		end

		bit_lit = Enum.take(decoder.stream, bits)
		{bit_lit, skip(decoder, bits)}
	end

	defp skip(decoder, amount) do
		new_stream = Enum.drop(decoder.stream, amount)
		new_decoder_read_count = decoder.read_count + amount
		%Decoder{stream: new_stream, read_count: new_decoder_read_count}
	end

	defp sub_stream_decoder(decoder, amount) do
		new_stream = Enum.take(decoder.stream, amount)
		%Decoder{stream: new_stream, read_count: 0}
	end

	defp has_more_data(decoder) do
		length(decoder.stream) > 0
	end

	def move_head_to_next_packet_start(decoder) do
		skip = 4 - rem(decoder.read_count, 4) #|> IO.inspect(label: "skip")
		skip(decoder, skip)
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

		if type == 4 do
			#IO.puts("Read literal #{version}")
			{literal, decoder} = Decoder.read_literal(decoder)
			{{version, type, literal}, decoder}
		else
			#IO.puts("Read operator #{version}")
			{pakets, decoder} =
			case read_operator_sub_packet_length(decoder) do
				{{:sub_packet_length_in_bits, sub_packets_length_in_bits}, new_decoder} -> read_sub_packets_by_bit_length(new_decoder, sub_packets_length_in_bits)
			  {{:sub_packets_count, sub_packets_count}, new_decoder} -> read_sub_packets_by_packet_count(new_decoder, sub_packets_count)
			end
			{{version, type, pakets}, decoder}
		end
	end

	def read_sub_packets_by_bit_length(decoder, bit_length) do
		#IO.puts("read_sub_packets_by_bit_length #{bit_length}")
		sub_decoder = sub_stream_decoder(decoder, bit_length)
		packets = read_packets(sub_decoder)

		next_decoder = skip(decoder, bit_length)
		{packets, next_decoder}
	end

	def read_sub_packets_by_packet_count(decoder, packet_count) do

		if packet_count < 1 do
			raise "Can not read less than one packet"
		end

		#IO.puts("read_sub_packets_by_packet_count #{packet_count}")
		{packet, decoder} = read_packet(decoder)
		if packet_count > 1 do
      {packets, decoder} = read_sub_packets_by_packet_count(decoder, packet_count - 1)
			{[packet | packets], decoder}
    else
			{[packet], decoder}
		end
	end


	def read_packets(decoder) do
		{packet, decoder} = read_packet(decoder) #|> IO.inspect(label: "Read single packet")
		if has_more_data(decoder) do
			[packet | read_packets(decoder)]
		else
			[packet]
		end
	end

	def read(decoder) do
		{data, _} = read_packet(decoder) #|> IO.inspect(label: "Read done")
		data
	end

end

defmodule Day16 do

	def sum({version, type, data}) do
		if type != 4 do
			sub_sum = Enum.map(data, &(sum(&1))) |> Enum.sum()
			version + sub_sum
		else
			version
		end
	end

	def map({e1, e2}, f) do
		if f.(e1, e2), do: 1, else: 0
	end

	def walk({version, type, data}) do

		case type do
			4 -> data

			# ID 0 are sum packets - their value is the sum of the values of their sub-packets. If they only have a single sub-packet, their value is the value of the sub-packet.
			0 -> Enum.map(data, &(walk(&1))) |> Enum.sum()

		  # ID 1 are product packets - their value is the result of multiplying together the values of their sub-packets. If they only have a single sub-packet, their value is the value of the sub-packet.
			1 -> Enum.map(data, &(walk(&1))) |> Enum.reduce(1, fn e, a -> e * a end)

			# ID 2 are minimum packets - their value is the minimum of the values of their sub-packets.
      2 -> Enum.map(data, &(walk(&1))) |> Enum.min()

			# ID 3 are maximum packets - their value is the maximum of the values of their sub-packets.
      3 -> Enum.map(data, &(walk(&1))) |> Enum.max()

			# ID 5 are greater than packets - their value is 1 if the value of the first sub-packet is greater than the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
			5 -> Enum.map(data, &(walk(&1))) |> List.to_tuple() |> map(fn e1, e2 -> e1 > e2 end)

			# ID 6 are less than packets - their value is 1 if the value of the first sub-packet is less than the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
			6 -> Enum.map(data, &(walk(&1))) |> List.to_tuple() |> map(fn e1, e2 -> e1 < e2 end)

      # ID 7 are equal to packets - their value is 1 if the value of the first sub-packet is equal to the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
			7 -> Enum.map(data, &(walk(&1))) |> List.to_tuple() |> map(fn e1, e2 -> e1 == e2 end)
		end
	end
end

input = File.stream!(filename) |> Enum.map(&String.trim/1) |> hd() #|> IO.inspect(label: "Input")

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

# sub_packet_length_in_bits
#decoder = Decoder.create("38006F45291200") |> IO.inspect(label: "Result Part 1")
#{_, decoder} = Decoder.read_version(decoder) |> IO.inspect(label: "Version")
#{_, decoder} = Decoder.read_type_id(decoder) |> IO.inspect(label: "Type Id")
#
#{{:sub_packet_length_in_bits, sub_packets_length_in_bits}, decoder} = Decoder.read_operator_sub_packet_length(decoder) |> IO.inspect(label: "Packet length")
#{_, decoder} = Decoder.read_sub_packets_by_bit_length(decoder, sub_packets_length_in_bits) |> IO.inspect(label: "Packet length")



#decoder = Decoder.create("EE00D40C823060") |> IO.inspect(label: "Result Part 1")
#{_, decoder} = Decoder.read_version(decoder) |> IO.inspect(label: "Version")
#{_, decoder} = Decoder.read_type_id(decoder) |> IO.inspect(label: "Type Id")
#
#{{:sub_packets_count, sub_packets_count}, decoder} = Decoder.read_operator_sub_packet_length(decoder) |> IO.inspect(label: "Packet length")
#{_, decoder} = Decoder.read_sub_packets_by_packet_count(decoder, sub_packets_count) |> IO.inspect(label: "Packet length")

#decoder = Decoder.create("EE00D40C823060") |> IO.inspect(label: "Result Part 1")
#Decoder.read_packet(decoder) |> IO.inspect(label: "Version")

# 8A004A801A8002F478 represents an operator packet (version 4) which contains an operator packet (version 1) which contains an operator packet (version 5) which contains a literal value (version 6); this packet has a version sum of 16.
#decoder = Decoder.create("8A004A801A8002F478")
#data = Decoder.read(decoder) |> IO.inspect(label: "Version")
#
#Day16.sum(data) |> IO.inspect(label: "Resul Part 1")

import ExUnit.Assertions

#assert 16 == Decoder.create("8A004A801A8002F478") |> Decoder.read() |>Day16.sum()
#IO.puts("Done 16")
#
#assert 12 == Decoder.create("620080001611562C8802118E34") |> Decoder.read() |> IO.inspect(label: "Data") |>Day16.sum()
#IO.puts("Done 12")
#
#assert 23 == Decoder.create("C0015000016115A2E0802F182340") |> Decoder.read() |>Day16.sum()
#IO.puts("Done 23")
#
#assert 31 == Decoder.create("A0016C880162017C3686B18A3D4780") |> Decoder.read() |>Day16.sum()
#IO.puts("Done 31")
#

#assert 3 == Decoder.create("C200B40A82") |> Decoder.read() |>Day16.walk()
#IO.puts("Done 3")
#
#assert 54 == Decoder.create("04005AC33890") |> Decoder.read() |>Day16.walk()


Decoder.create(input) |> Decoder.read() |>Day16.sum() |> IO.inspect(label: "Part 1")
Decoder.create(input) |> Decoder.read() |>Day16.walk() |> IO.inspect(label: "Part 2")