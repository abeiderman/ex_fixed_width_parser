defmodule ExFixedWidthParser.OverpunchParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.OverpunchParser
  alias ExFixedWidthParser.OverpunchParser

  describe "parse/1" do
    test "parses positive integers" do
      [
        ["45{", 450],
        ["45A", 451],
        ["45B", 452],
        ["45C", 453],
        ["45D", 454],
        ["45E", 455],
        ["45F", 456],
        ["45G", 457],
        ["45H", 458],
        ["45I", 459],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert OverpunchParser.parse(input) == {:ok, expected}
        end
      )
    end

    test "parses negative integers" do
      [
        ["45}", -450],
        ["45J", -451],
        ["45K", -452],
        ["45L", -453],
        ["45M", -454],
        ["45N", -455],
        ["45O", -456],
        ["45P", -457],
        ["45Q", -458],
        ["45R", -459],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert OverpunchParser.parse(input) == {:ok, expected}
        end
      )
    end
  end

  describe "parse/2" do
    test "parses positive decimals" do
      [
        ["1045{", Decimal.new("104.50")],
        ["1045A", Decimal.new("104.51")],
        ["1045B", Decimal.new("104.52")],
        ["1045C", Decimal.new("104.53")],
        ["1045D", Decimal.new("104.54")],
        ["1045E", Decimal.new("104.55")],
        ["1045F", Decimal.new("104.56")],
        ["1045G", Decimal.new("104.57")],
        ["1045H", Decimal.new("104.58")],
        ["1045I", Decimal.new("104.59")],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert OverpunchParser.parse(input, 2) == {:ok, expected}
        end
      )
    end

    test "parses negative decimals" do
      [
        ["1045}", Decimal.new("-104.50")],
        ["1045J", Decimal.new("-104.51")],
        ["1045K", Decimal.new("-104.52")],
        ["1045L", Decimal.new("-104.53")],
        ["1045M", Decimal.new("-104.54")],
        ["1045N", Decimal.new("-104.55")],
        ["1045O", Decimal.new("-104.56")],
        ["1045P", Decimal.new("-104.57")],
        ["1045Q", Decimal.new("-104.58")],
        ["1045R", Decimal.new("-104.59")],
      ]
      |> Enum.each(
        fn ([input, expected]) ->
          assert OverpunchParser.parse(input, 2) == {:ok, expected}
        end
      )
    end

    test "returns an error when given an empty string" do
      assert {:error, nil} = OverpunchParser.parse("")
      assert {:error, nil} = OverpunchParser.parse("  ")
      assert {:error, nil} = OverpunchParser.parse("", 2)
      assert {:error, nil} = OverpunchParser.parse("   ", 2)
    end

    test "returns an error when given nil" do
      assert {:error, nil} = OverpunchParser.parse(nil)
      assert {:error, nil} = OverpunchParser.parse(nil, 2)
    end
  end
end
