defmodule ExFixedWidthParser.DateParser do
  def parse(string, [year: year_range, month: month_range, day: day_range]) when is_bitstring(string) do
    year = parse_year(string, year_range)
    month = parse_month_or_day(string, month_range)
    day = parse_month_or_day(string, day_range)

    case Date.from_iso8601("#{year}-#{month}-#{day}") do
      {:error, _} -> :error
      result -> result
    end
  end

  defp parse_year(string, range) do
    string |> String.slice(range) |> String.trim() |> pad_if_length(2, "20")
  end

  defp parse_month_or_day(string, range) do
    string |> String.slice(range) |> String.trim() |> pad_if_length(1, "0")
  end

  defp pad_if_length(string, len, pad) when byte_size(string) == len, do: "#{pad}#{string}"
  defp pad_if_length(string, _, _), do: string
end
