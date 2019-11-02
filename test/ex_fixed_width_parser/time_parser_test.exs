defmodule ExFixedWidthParser.TimeParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.TimeParser
  alias ExFixedWidthParser.TimeParser

  describe "parse/2" do
    test "parses HHMMSS times" do
      format = [hour: 0..1, minute: 2..3, second: 4..5]

      [
        ["035901", ~T[03:59:01]],
        ["000000", ~T[00:00:00]],
        ["235959", ~T[23:59:59]],
        [" 3 0 5", ~T[03:00:05]],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert TimeParser.parse(input, format) == {:ok, expected}
        end
      )
    end

    test "parses HHMM times" do
      format = [hour: 0..1, minute: 2..3]

      [
        ["0359", ~T[03:59:00]],
        ["0000", ~T[00:00:00]],
        ["2359", ~T[23:59:00]],
        [" 3 0", ~T[03:00:00]],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert TimeParser.parse(input, format) == {:ok, expected}
        end
      )
    end

    test "returns error when the time is malformed" do
      format = [hour: 0..1, minute: 2..3, second: 4..5]

      [
        "245900",
        "206000",
        "205960",
        "2A5959",
      ]
      |> Enum.each(
        fn (input) ->
          assert TimeParser.parse(input, format) == :error
        end
      )
    end
  end
end
