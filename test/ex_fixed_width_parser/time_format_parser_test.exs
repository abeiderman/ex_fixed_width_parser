defmodule ExFixedWidthParser.TimeFormatParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.TimeFormatParser
  alias ExFixedWidthParser.TimeFormatParser

  describe "parse/1" do
    test "parses formats into a keyword list of ranges" do
      [
        ["HHMMSS", [hour: 0..1, minute: 2..3, second: 4..5]],
        ["HH:MM:SS", [hour: 0..1, minute: 3..4, second: 6..7]],
        ["HHMM", [hour: 0..1, minute: 2..3]],
        ["HH:MM", [hour: 0..1, minute: 3..4]],
        ["SSMMHH", [hour: 4..5, minute: 2..3, second: 0..1]],
      ]
      |> Enum.each(
        fn ([format_string, format]) ->
          assert {:ok, parsed_format} = TimeFormatParser.parse(format_string)
          assert parsed_format == format
        end
      )
    end

    test "returns error for incomplete or invalid formats" do
      [
        "HH",
        "MM",
        "SS",
        "MMSS",
        "   ",
        "",
        nil,
      ]
      |> Enum.each(
        fn (format_string) ->
          assert TimeFormatParser.parse(format_string) == :error
        end
      )
    end
  end
end

