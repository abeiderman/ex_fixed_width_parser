defmodule ExFixedWidthParser.TimeParser do
  def parse(string, [hour: hour_range, minute: minute_range, second: second_range]) when is_bitstring(string) do
    parse_time(
      string |> parse_component(hour_range),
      string |> parse_component(minute_range),
      string |> parse_component(second_range)
    )
  end

  def parse(string, [hour: hour_range, minute: minute_range]) when is_bitstring(string) do
    parse_time(
      string |> parse_component(hour_range),
      string |> parse_component(minute_range),
      "00"
    )
  end

  defp parse_time(hour, minute, second) do
    case Time.from_iso8601("#{hour}:#{minute}:#{second}") do
      {:error, _} -> :error
      {:ok, time} -> {:ok, time}
    end
  end

  defp parse_component(string, range) do
    string |> String.slice(range) |> String.trim() |> zero_pad()
  end

  defp zero_pad(string) when byte_size(string) == 1, do: "0#{string}"
  defp zero_pad(string), do: string
end
