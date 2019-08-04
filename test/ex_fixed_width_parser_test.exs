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

    test "parses numbers in overpunch format" do
      value = """
              1652{1653E
              2652}0653N
              """
      format = %{
        1..5 => [:amount, :overpunch],
        6..10 => [:fee, overpunch: [decimals: 2]],
      }

      assert {:ok, result} = parse(value, format)

      assert result == [
        %{amount: 16520, fee: Decimal.new("165.35")},
        %{amount: -26520, fee: Decimal.new("-65.35")},
      ]
    end

    test "it returns a warning when there are overpunch parsing errors" do
      value = """
              1D52{1653E
              2652} 3532
              """
      format = %{
        1..5 => [:amount, :overpunch],
        6..10 => [:fee, overpunch: [decimals: 2]],
      }

      assert {:warn, [data: data, errors: [first_error, second_error]]} = parse(value, format)

      assert data == [
        %{amount: nil, fee: Decimal.new("165.35")},
        %{amount: -26520, fee: nil},
      ]

      assert first_error[:line_number] == 1
      assert first_error[:columns] == 1..5
      assert first_error[:name] == :amount
      assert first_error[:type] == :overpunch
      assert Regex.match?(~r/overpunch/, first_error[:message])

      assert second_error[:line_number] == 2
      assert second_error[:columns] == 6..10
      assert second_error[:name] == :fee
      assert second_error[:type] == {:overpunch, [decimals: 2]}
      assert Regex.match?(~r/overpunch/, second_error[:message])
    end

    test "parses undelimited decimal numbers" do
      value = """
              1652016535
              2652306535
              """
      format = %{
        1..5 => [:amount, :decimal],
        6..10 => [:fee, decimal: [decimals: 2]],
      }

      assert {:ok, result} = parse(value, format)

      assert result == [
        %{amount: Decimal.new(16520), fee: Decimal.new("165.35")},
        %{amount: Decimal.new(26523), fee: Decimal.new("65.35")},
      ]
    end

    test "it returns a warning when there are decimal parsing errors" do
      value = """
              16F2016535
              265230653X
              """
      format = %{
        1..5 => [:amount, :decimal],
        6..10 => [:fee, decimal: [decimals: 2]],
      }

      assert {:warn, [data: data, errors: [first_error, second_error]]} = parse(value, format)

      assert data == [
        %{amount: nil, fee: Decimal.new("165.35")},
        %{amount: Decimal.new(26523), fee: nil},
      ]

      assert first_error[:line_number] == 1
      assert first_error[:columns] == 1..5
      assert first_error[:name] == :amount
      assert first_error[:type] == :decimal
      assert Regex.match?(~r/decimal/, first_error[:message])

      assert second_error[:line_number] == 2
      assert second_error[:columns] == 6..10
      assert second_error[:name] == :fee
      assert second_error[:type] == {:decimal, [decimals: 2]}
      assert Regex.match?(~r/decimal/, second_error[:message])
    end

    test "it parses dates" do
      value = """
              19072007222019
              18100110032018
              """
      format = %{
        1..6 => [:transaction_date, date: [format: "YYMMDD"]],
        7..14 => [:post_date, date: [format: "MMDDYYYY"]]
      }

      assert {:ok, result} = parse(value, format)

      assert result == [
        %{transaction_date: Date.new(2019, 7, 20), post_date: Date.new(2019, 7, 22)},
        %{transaction_date: Date.new(2018, 10, 1), post_date: Date.new(2018, 10, 3)},
      ]
    end

    test "it returns a warning when there are date parsing errors" do
      value = """
              190V2007222019
              1810011003X018
              """
      format = %{
        1..6 => [:transaction_date, date: [format: "YYMMDD"]],
        7..14 => [:post_date, date: [format: "MMDDYYYY"]]
      }

      assert {:warn, [data: data, errors: [first_error, second_error]]} = parse(value, format)

      assert data == [
        %{transaction_date: nil, post_date: Date.new(2019, 7, 22)},
        %{transaction_date: Date.new(2018, 10, 1), post_date: nil},
      ]
      assert first_error[:line_number] == 1
      assert first_error[:columns] == 1..6
      assert first_error[:name] == :transaction_date
      assert first_error[:type] == {:date, [format: "YYMMDD"]}
      assert Regex.match?(~r/date/, first_error[:message])

      assert second_error[:line_number] == 2
      assert second_error[:columns] == 7..14
      assert second_error[:name] == :post_date
      assert second_error[:type] == {:date, [format: "MMDDYYYY"]}
      assert Regex.match?(~r/date/, second_error[:message])
    end
  end

  defp parse(value, format) do
    {:ok, result} = value |> StringIO.open(&(ExFixedWidthParser.parse(&1, format)))

    result
  end
end
