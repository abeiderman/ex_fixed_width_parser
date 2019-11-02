defmodule ExFixedWidthParser.DateParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.DateParser
  alias ExFixedWidthParser.DateParser

  describe "parse/2" do
    test "parses YYMMDD dates" do
      format = [year: 0..1, month: 2..3, day: 4..5]

      [
        ["200101", ~D[2020-01-01]],
        ["190406", ~D[2019-04-06]],
        ["190430", ~D[2019-04-30]],
        ["201231", ~D[2020-12-31]],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert DateParser.parse(input, format) == {:ok, expected}
        end
      )
    end

    test "parses YYYYMMDD dates" do
      format = [year: 0..3, month: 4..5, day: 6..7]

      [
        ["20200101", ~D[2020-01-01]],
        ["20190406", ~D[2019-04-06]],
        ["20190430", ~D[2019-04-30]],
        ["20201231", ~D[2020-12-31]],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert DateParser.parse(input, format) == {:ok, expected}
        end
      )
    end

    test "parses MM/DD/YY dates" do
      format = [year: 6..7, month: 0..1, day: 3..4]

      [
        ["01/01/20", ~D[2020-01-01]],
        [" 1/ 1/20", ~D[2020-01-01]],
        ["04/06/19", ~D[2019-04-06]],
        [" 4/ 6/19", ~D[2019-04-06]],
        ["04/30/19", ~D[2019-04-30]],
        [" 4/30/19", ~D[2019-04-30]],
        ["12/31/20", ~D[2020-12-31]],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert DateParser.parse(input, format) == {:ok, expected}
        end
      )
    end

    test "returns error when the date is malformed" do
      format = [year: 6..7, month: 0..1, day: 3..4]

      [
        "1//01/20",
        "AB/03/20",
        "01/.3/20",
        "01/03/--",
      ]
      |> Enum.each(
        fn (input) ->
          assert DateParser.parse(input, format) == :error
        end
      )
    end
  end
end
