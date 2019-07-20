defmodule ExFixedWidthParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser

  describe "parse/2" do
    test "parses integer values" do
      value = """
              20190714
              20190718
              """
      format = %{
        1..4 => [:year, :integer],
        5..6 => [:month, :integer],
        7..8 => [:day, :integer],
      }

      assert {:ok, result} = parse(value, format)

      assert result == [
        %{year: 2019, month: 7, day: 14},
        %{year: 2019, month: 7, day: 18},
      ]
    end

    test "parses text values" do
      value = """
              ABfoo 123
              CDbar9810
              """
      format = %{
        1..2 => [:prefix, :text],
        3..9 => [:word, :text],
      }

      assert {:ok, result} = parse(value, format)

      assert result == [
        %{prefix: "AB", word: "foo 123"},
        %{prefix: "CD", word: "bar9810"},
      ]
    end

    test "parses using a custom parser" do
      value = """
              10AB
              20CD
              """
      format = %{
        1..2 => [:number, fn (data) -> {:ok, String.to_integer(data) * 3} end],
        3..4 => [:word, fn (data) -> {:ok, "#{data}-parsed"} end],
      }

      assert {:ok, result} = parse(value, format)

      assert result == [
        %{number: 30, word: "AB-parsed"},
        %{number: 60, word: "CD-parsed"},
      ]
    end

    test "it returns a warning when there are integer parsing errors" do
      value = """
              2019071Y
              2019R718
              """
      format = %{
        1..4 => [:year, :integer],
        5..6 => [:month, :integer],
        7..8 => [:day, :integer],
      }

      assert {:warn, [data: data, errors: [first_error, second_error]]} = parse(value, format)

      assert data == [
        %{year: 2019, month: 7, day: 1},
        %{year: 2019, month: nil, day: 18},
      ]

      assert first_error[:line_number] == 1
      assert first_error[:columns] == 7..8
      assert first_error[:name] == :day
      assert first_error[:type] == :integer
      assert Regex.match?(~r/substring.*Y.*integer/, first_error[:message])

      assert second_error[:line_number] == 2
      assert second_error[:columns] == 5..6
      assert second_error[:name] == :month
      assert second_error[:type] == :integer
      assert Regex.match?(~r/parse.*R7/, second_error[:message])
    end
  end

  defp parse(value, format) do
    {:ok, result} = value |> StringIO.open(&(ExFixedWidthParser.parse(&1, format)))

    result
  end
end