defmodule ExFixedWidthParser do
  def parse(input_io, format, enhancer \\ fn(l, _) -> l end) do
    lines = parse_lines([], input_io, format, enhancer)

    if lines |> Enum.any?(fn (i) -> Map.has_key?(i, :errors) end) do
      {:warn, lines}
    else
      {:ok, lines}
    end
  end

  defp parse_lines(list, input_io, format, enhancer) do
    case IO.read(input_io, :line) do
      :eof -> list
      line ->
        parse_lines(
          list ++ [parse_line(Enum.count(list) + 1, line, format, enhancer)],
          input_io,
          format,
          enhancer
        )
    end
  end

  defp parse_line(line_number, line, format_func, enhancer) when is_function(format_func) do
    parse_line(line_number, line, format_func.(line_number, line), enhancer)
  end

  defp parse_line(line_number, line, format, enhancer) do
    format
    |> Map.keys()
    |> Enum.map(&parse_line_slice(line_number, line, &1, format[&1]))
    |> construct_line_result()
    |> enhancer.(line_number)
  end

  defp parse_line_slice(line_number, line, range, [name, type]) do
    case line |> line_slice(range) |> parse_value(type) do
      {:ok, val} -> [tuple: {name, val}]
      {_, val, error} ->
        [
          tuple: {name, val},
          error: %{message: error, line_number: line_number, columns: range, name: name, type: type}
        ]
    end
  end

  defp construct_line_result(parsed_values) do
    case {map_from_line(parsed_values), errors_from_line(parsed_values)}  do
      {line_map, []} -> %{data: line_map}
      {line_map, errors} -> %{data: line_map, errors: errors}
    end
  end

  defp map_from_line(parsed_values), do: parsed_values |> Enum.map(& &1[:tuple]) |> Map.new

  defp errors_from_line(parsed_values) do
    parsed_values
    |> Enum.filter(& Keyword.has_key?(&1, :error))
    |> Enum.map(& &1[:error])
  end

  defp line_slice(line, first..last), do: {:ok, line |> String.slice((first - 1)..(last - 1))}

  defp parse_value({:ok, string}, type), do: parse_value(string, type)

  defp parse_value(string, :integer) do
    case Integer.parse(string) do
      :error -> {:error, nil, "Unable to parse '#{string}' as an integer"}
      {val, ""} -> {:ok, val}
      {val, extra} -> {:warn, val, "The substring '#{extra}' of '#{string}' could not be parsed as an integer"}
    end
  end

  defp parse_value(string, :text), do: {:ok, string}

  defp parse_value(string, :decimal), do: parse_value(string, {:decimal, [decimals: 0]})
  defp parse_value(string, {:decimal, options}) do
    case ExFixedWidthParser.DecimalParser.parse(string, options) do
      {:ok, val} -> {:ok, val}
      :error ->
        {
          :error,
          nil,
          "Unable to parse '#{string}' as a decimal numeric value with options #{inspect(options)}"
        }
    end
  end

  defp parse_value(string, {:date, [format: format]}) do
    with {:ok, date_format} <- ExFixedWidthParser.DateFormatParser.parse(format),
         {:ok, parsed_date} <- ExFixedWidthParser.DateParser.parse(string, date_format)
    do
      {:ok, parsed_date}
    else
      :error ->
        {
          :error,
          nil,
          "Unable to parse date '#{string}' with format '#{format}'"
        }
    end
  end

  defp parse_value(string, {:time, [format: format]}) do
    with {:ok, time_format} <- ExFixedWidthParser.TimeFormatParser.parse(format),
         {:ok, parsed_time} <- ExFixedWidthParser.TimeParser.parse(string, time_format)
    do
      {:ok, parsed_time}
    else
      :error ->
        {
          :error,
          nil,
          "Unable to parse time '#{string}' with format '#{format}'"
        }
    end
  end

  defp parse_value(string, :overpunch), do: parse_value(string, {:overpunch, [decimals: 0]})
  defp parse_value(string, {:overpunch, [decimals: decimals]}) do
    case ExFixedWidthParser.OverpunchParser.parse(string, decimals) do
      {:ok, val} -> {:ok, val}
      {:error, val} ->
        {
          :error,
          val,
          "Unable to parse '#{string}' as an overpunch numeric value with #{decimals} decimal places"
        }
    end
  end

  defp parse_value(string, func) when is_function(func), do: func.(string)
end
