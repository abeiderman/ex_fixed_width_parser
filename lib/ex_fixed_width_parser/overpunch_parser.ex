defmodule ExFixedWidthParser.OverpunchParser do
  def parse(nil), do: parse(nil, 0)
  def parse(string), do: parse(String.trim(string), 0)

  def parse(nil, _), do: {:error, nil}
  def parse(string, decimals) when is_bitstring(string) and is_integer(decimals) and decimals >= 0 do
    do_parse(String.trim(string), decimals)
  end

  defp do_parse("", _), do: {:error, nil}

  defp do_parse(string, 0) do
    {sign, integer} = parse_as_integer(string)
    {:ok, sign * integer}
  end

  defp do_parse(string, decimals) when is_integer(decimals) and decimals > 0 do
    {sign, integer} = parse_as_integer(string)
    {:ok, Decimal.new(sign, abs(integer), -decimals)}
  end

  defp parse_as_integer(string) do
    {last_digit, sign} = string |> String.last |> convert_last_digit
    numeric_part = String.slice(string, 0..-2)

    {sign, String.to_integer("#{numeric_part}#{last_digit}")}
  end

  defp convert_last_digit(digit) do
    case digit do
      "}" -> {0, -1}
      "J" -> {1, -1}
			"K" -> {2, -1}
			"L" -> {3, -1}
			"M" -> {4, -1}
			"N" -> {5, -1}
			"O" -> {6, -1}
			"P" -> {7, -1}
			"Q" -> {8, -1}
			"R" -> {9, -1}
      "{" -> {0, 1}
      "A" -> {1, 1}
      "B" -> {2, 1}
      "C" -> {3, 1}
      "D" -> {4, 1}
      "E" -> {5, 1}
      "F" -> {6, 1}
      "G" -> {7, 1}
      "H" -> {8, 1}
      "I" -> {9, 1}
    end
  end
end
