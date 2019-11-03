defmodule ExFixedWidthParser.Amex.EptrnParserTest do
  use ExUnit.Case
  doctest ExFixedWidthParser.Amex.EptrnParser
  alias ExFixedWidthParser.Amex.EptrnParser

  setup do
    {:ok, file_path: "test/ex_fixed_width_parser/amex/fixtures/dummy_eptrn_raw"}
  end

  test "foo", context do
    contents = File.read!(context[:file_path])
    IO.puts(contents)

    {:ok, list} = EptrnParser.parse(context[:file_path])

    IO.inspect(list)
  end

  test "parses the header record", context do
    {:ok, list} = EptrnParser.parse(context[:file_path])

    [%{data: data} | _] = list

    assert data[:type] == :file_header
    assert data[:type_code] == "DFHDR"
    assert data[:date] == ~D[2013-03-08]
    assert data[:time] == ~T[04:52:00]
    assert data[:file_id] == 0
    assert data[:file_name] == "LUMOS LABS INC      "
  end

  test "parses the trailer record", context do
    {:ok, list} = EptrnParser.parse(context[:file_path])

    %{data: data} = list |> List.last()

    assert data[:type] == :file_trailer
    assert data[:type_code] == "DFTRL"
    assert data[:date] == ~D[2013-03-08]
    assert data[:time] == ~T[04:52:00]
    assert data[:file_id] == 0
    assert data[:file_name] == "LUMOS LABS INC      "
    assert data[:recipient_key] == "00000000003491124567          0000000000"
    assert data[:record_count] == 4
  end

  test "parses a summary record", context do
    {:ok, list} = EptrnParser.parse(context[:file_path])

    %{data: data} = list |> Enum.find(fn i -> i[:data][:type] == :summary_record end)

    assert data[:type] == :summary_record
    assert data[:type_code] == "00"
    assert data[:record_type_code] == "1"
    assert data[:amex_payee_number] == 3491124567
    assert data[:amex_sort_field_1] == "0000000000"
    assert data[:amex_sort_field_2] == "0000000000"
    assert data[:payment_year] == 2013
    assert data[:payment_number] == "DUMT1234"
    assert data[:payment_date] == ~D[2013-03-09]
    assert data[:payment_amount] == Decimal.new("50035.54")
    assert data[:debit_balance_amount] == Decimal.new("0.00")
    assert data[:aba_bank_number] == 121140399
    assert data[:se_dda_number] == 4000
  end

  test "parses a summary of charge detail record", context do
    {:ok, list} = EptrnParser.parse(context[:file_path])

    %{data: data} = list |> Enum.find(fn i -> i[:data][:type] == :summary_of_charge_detail_record end)

    assert data[:type] == :summary_of_charge_detail_record
    assert data[:type_code] == "10"
    assert data[:record_type_code] == "2"
    assert data[:amex_payee_number] == 3491124567
    assert data[:amex_se_number] == 3491124567
    assert data[:se_unit_number] == "          "
    assert data[:payment_year] == 2013
    assert data[:payment_number] == "DUMT1234"
    assert data[:se_business_date] == ~D[2013-03-06]
    assert data[:amex_process_date] == ~D[2013-03-06]
    assert data[:soc_invoice_number] == 140
    assert data[:soc_amount] == Decimal.new("50035.54")
    assert data[:discount_amount] == Decimal.new("835.48")
    assert data[:service_fee_amount] == Decimal.new("7.38")
    assert data[:net_soc_amount] == Decimal.new("50035.54")
    assert data[:discount_rate] == 3500
    assert data[:service_fee_rate] == 30
    assert data[:amex_gross_amount] == Decimal.new("50035.54")
    assert data[:amex_roc_count] == 405
    assert data[:tracking_id] == 65013192
    assert data[:cpc_indicator] == " "
    assert data[:amex_ro_count_poa] == 405
  end
end
