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

    [%{data: data} | _] = list

    assert data[:type] == :file_header
    assert data[:type_code] == "DFHDR"
    assert data[:date] == Date.new(2013, 3, 8)
    assert data[:time] == Time.new(4, 52, 0)
    assert data[:file_id] == 0
    assert data[:file_name] == "LUMOS LABS INC      "
  end

  test "parses the trailer record", context do
    {:ok, list} = EptrnParser.parse(context[:file_path])

    %{data: data} = list |> List.last()

    assert data[:type] == :file_trailer
    assert data[:type_code] == "DFTRL"
    assert data[:date] == Date.new(2013, 3, 8)
    assert data[:time] == Time.new(4, 52, 0)
    assert data[:file_id] == 0
    assert data[:file_name] == "LUMOS LABS INC      "
    assert data[:recipient_key] == "00000000003491124567          0000000000"
    assert data[:record_count] == 4
  end
end
