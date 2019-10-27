defmodule ExFixedWidthParser.TimeParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.TimeParser
  alias ExFixedWidthParser.TimeParser

  describe "parse/2" do
    test "parses HHMMSS times" do
      format = [hour: 0..1, minute: 2..3, second: 4..5]

      [
        ["035901", Time.new(3, 59, 1)],
        ["000000", Time.new(0, 0, 0)],
        ["235959", Time.new(23, 59, 59)],
        [" 3 0 5", Time.new(3, 0, 5)],
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
        ["0359", Time.new(3, 59, 0)],
        ["0000", Time.new(0, 0, 0)],
        ["2359", Time.new(23, 59, 0)],
        [" 3 0", Time.new(3, 0, 0)],
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
