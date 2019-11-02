defmodule ExFixedWidthParser.JulianDateParser do
  def parse(string) when is_bitstring(string) do
    julian_date(
      parse_integer(string, 0..3),
      parse_integer(string, 4..6)
    )
  end

  defp parse_integer(string, range) do
    case string |> String.slice(range) |> String.trim() |> Integer.parse() do
      {int, ""} -> int
      _ -> :error
    end
  end

  defp julian_date(_, :error), do: :error
  defp julian_date(:error, _), do: :error
  defp julian_date(_, day) when is_integer(day) and day < 1, do: :error

  defp julian_date(year, day) when is_integer(year) and is_integer(day) do
    with {:ok, start_date} <- Date.new(year, 1, 1),
         date <- Date.add(start_date, day - 1)
    do
      {:ok, date}
    else
      {:error, _} -> :error
    end
  end
end
