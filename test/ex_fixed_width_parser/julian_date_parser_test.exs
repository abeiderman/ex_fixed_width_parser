defmodule ExFixedWidthParser.JulianDateParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.JulianDateParser
  alias ExFixedWidthParser.JulianDateParser

  describe "parse/1" do
    test "parses valid julian dates" do
      [
        ["2020001", ~D[2020-01-01]],
        ["2019096", ~D[2019-04-06]],
        ["2019120", ~D[2019-04-30]],
        ["2020366", ~D[2020-12-31]],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert JulianDateParser.parse(input) == {:ok, expected}
        end
      )
    end

    test "returns error when the date is malformed" do
      [
        "2019000",
        "2020-10",
        "201900A",
        "191B001",
      ]
      |> Enum.each(
        fn (input) ->
          assert JulianDateParser.parse(input) == :error
        end
      )
    end
  end
end
