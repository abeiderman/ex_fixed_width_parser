defmodule ExFixedWidthParser.DecimalParser do
  def parse(nil), do: parse(nil, [])
  def parse(string), do: parse(string, [decimals: 0])

  def parse(nil, _), do: :error
  def parse(string, options), do: do_parse(String.trim_leading(string), options)

  defp do_parse("", _), do: :error
  defp do_parse(string, [decimals: decimals]), do: do_parse(string, [decimals: decimals, trim_right: false])
  defp do_parse(string, [decimals: decimals, trim_right: false]) when is_integer(decimals) do
    do_parse(string, decimals)
  end
  defp do_parse(string, [decimals: decimals, trim_right: true]) when is_integer(decimals) do
    string |> String.trim_trailing() |> do_parse(decimals)
  end

  defp do_parse(string, decimals) when is_bitstring(string) and is_integer(decimals) do
    case Integer.parse(string) do
      {integer, ""} -> {:ok, Decimal.new(1, integer, -decimals)}
      _ -> :error
    end
  end
end
