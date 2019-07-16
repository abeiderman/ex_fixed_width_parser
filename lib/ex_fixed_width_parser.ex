defmodule ExFixedWidthParser do
  def parse(input_io, format) do
    case parse_lines([], input_io, format) do
      {lines, []} -> {:ok, lines }
      {lines, errors}  -> {:warn, [data: lines, errors: errors]}
    end
  end

  defp parse_lines(list, input_io, format) do
    case IO.read(input_io, :line) do
      :eof -> flatten_list(list)
      line -> parse_lines(list ++ [parse_line(Enum.count(list) + 1, line, format)], input_io, format)
    end
  end

  defp flatten_list(list) do
    {
      list |> Enum.map(& &1[:line]),
      list |> Enum.filter(& Keyword.has_key?(&1, :errors)) |> Enum.flat_map(& &1[:errors]),
    }
  end

  defp parse_line(line_number, line, format) do
    format
    |> Map.keys()
    |> Enum.map(&parse_line_slice(line_number, line, &1, format[&1]))
    |> construct_line_result()
  end

  defp parse_line_slice(line_number, line, range, [name, type]) do
    case line |> line_slice(range) |> parse_value(type) do
      {:ok, val, _} -> [tuple: {name, val}]
      {_, val, error} ->
        [
          tuple: {name, val},
          error: %{message: error, line_number: line_number, columns: range, name: name, type: type}
        ]
    end
  end

  defp construct_line_result(parsed_values) do
    case {map_from_line(parsed_values), errors_from_line(parsed_values)}  do
      {line_map, []} -> [line: line_map]
      {line_map, errors} -> [line: line_map, errors: errors]
    end
  end

  def map_from_line(parsed_values) do
    parsed_values |> Enum.map(& &1[:tuple]) |> Map.new
  end

  defp errors_from_line(parsed_values) do
    parsed_values
    |> Enum.filter(& Keyword.has_key?(&1, :error))
    |> Enum.map(& &1[:error])
  end

  defp line_slice(line, first..last) do
    {:ok, line |> String.slice((first - 1)..(last - 1))}
  end

  defp parse_value({:ok, string}, type), do: parse_value(string, type)

  defp parse_value(string, :integer) do
    case Integer.parse(string) do
      :error -> {:error, nil, "Unable to parse '#{string}' as an integer"}
      {val, ""} -> {:ok, val, nil}
      {val, extra} -> {:warn, val, "The substring '#{extra}' of '#{string}' could not be parsed as an integer"}
    end
  end

  defp parse_value(string, :text), do: {:ok, string, nil}
end
