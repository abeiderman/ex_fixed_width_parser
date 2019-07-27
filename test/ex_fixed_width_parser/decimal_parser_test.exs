defmodule ExFixedWidthParser.DecimalParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.DecimalParser
  alias ExFixedWidthParser.DecimalParser

  describe "parse/2" do
    test "parses non-delimited decimals" do
      [
        ["004512", Decimal.new("45.12")],
        ["004502", Decimal.new("45.02")],
        ["004510", Decimal.new("45.10")],
        ["004500", Decimal.new("45.00")],
        ["000003", Decimal.new("0.03")],
        ["000000", Decimal.new("0.00")],
        ["  4500", Decimal.new("45.00")],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert DecimalParser.parse(input, [decimals: 2]) == {:ok, expected}
        end
      )
    end

    test "returns error when given bad data" do
      [
        "ABCDF12",
        "12XYZ",
        "45.12",
        "45   ",
      ]
      |> Enum.each(
        fn (input) ->
          assert DecimalParser.parse(input, [decimals: 2]) == :error
        end
      )
    end

    test "ignores trailing spaces when given trim_right: true as an option" do
      [
        ["45   ", Decimal.new("0.45")],
        ["4512 ", Decimal.new("45.12")],
        ["450  ", Decimal.new("4.50")],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert DecimalParser.parse(input, [decimals: 2, trim_right: true]) == {:ok, expected}
        end
      )
    end

    test "returns an error when given an empty string" do
      assert :error = DecimalParser.parse("")
      assert :error = DecimalParser.parse("  ")
      assert :error = DecimalParser.parse("", [decimals: 2])
      assert :error = DecimalParser.parse("   ", [decimals: 2])
    end

    test "returns an error when given nil" do
      assert :error = DecimalParser.parse(nil)
      assert :error = DecimalParser.parse(nil, [decimals: 2])
    end
  end
end
