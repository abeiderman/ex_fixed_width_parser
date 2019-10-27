defmodule ExFixedWidthParser.Amex.EptrnParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.Amex.EptrnParser
  alias ExFixedWidthParser.Amex.EptrnParser

  setup do
    {:ok, file_path: "test/ex_fixed_width_parser/amex/fixtures/dummy_eptrn_raw"}
  end

  test "foo", context do
    contents = File.read!(context[:file_path])
    IO.puts(contents)

    {:ok, list} = EptrnParser.parse(context[:file_path])

    IO.inspect(list)
  end

  test "parses the header record", context do
    {:ok, list} = EptrnParser.parse(context[:file_path])

    [header | _] = list

    IO.inspect(header)
    assert header[:data][:type] == :file_header
    assert header[:data][:type_code] == "DFHDR"
    assert header[:data][:date] == Date.new(2013, 3, 8)
    assert header[:data][:time] == Time.new(4, 52, 0)
    assert header[:data][:file_id] == 0
    assert header[:data][:file_name] == "LUMOS LABS INC      "
  end
end
