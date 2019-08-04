defmodule ExFixedWidthParser.DateFormatParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.DateFormatParser
  alias ExFixedWidthParser.DateFormatParser

  describe "parse/1" do
    test "parses formats into a keyword list of ranges" do
      [
        ["YYMMDD", [year: 0..1, month: 2..3, day: 4..5]],
        ["YYYYMMDD", [year: 0..3, month: 4..5, day: 6..7]],
        ["YYYY-MM-DD", [year: 0..3, month: 5..6, day: 8..9]],
        ["YYYY/MM/DD", [year: 0..3, month: 5..6, day: 8..9]],
        ["MM/DD/YYYY", [year: 6..9, month: 0..1, day: 3..4]],
        ["DD/MM/YYYY", [year: 6..9, month: 3..4, day: 0..1]],
      ]
      |> Enum.each(
        fn ([format_string, format]) ->
          assert {:ok, parsed_format} = DateFormatParser.parse(format_string)
          assert parsed_format == format
        end
      )
    end

    test "returns error for incomplete or invalid formats" do
      [
        "YYMM",
        "MMDD",
        "YYYYDD",
        "FFGGPP",
        "   ",
        "",
        nil,
      ]
      |> Enum.each(
        fn (format_string) ->
          assert DateFormatParser.parse(format_string) == :error
        end
      )
    end
  end
end
