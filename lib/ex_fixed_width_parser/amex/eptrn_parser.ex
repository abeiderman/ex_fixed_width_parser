defmodule ExFixedWidthParser.Amex.EptrnParser do
  @type_codes %{
    "DFHDR" => :file_header,
    "00" => :summary_record,
    "10" => :summary_of_charge_detail_record,
    "11" => :record_of_charge_detail_record,
    "20" => :chargeback_detail_record,
    "30" => :adjustment_detail_record,
    "50" => :other_fees_and_revenues_detail_record,
    "DFTRL" => :file_trailer
  }

  def parse(file_path) do
    total_lines = file_path |> File.stream!([:read], :line) |> Enum.count

    file_path |> File.open!([:read], fn(file_io) ->
      file_io |> ExFixedWidthParser.parse(&(format(&1, total_lines, &2)), &enhancer(&1, &2))
    end)
  end

  defp enhancer(line, line_number) do
    line |> Map.merge(
      %{data: line[:data] |> Map.merge(%{type: @type_codes[line[:data][:type_code]]})}
    )
  end

  defp format(1, _total_lines, _line) do
    %{
      1..5 => [:type_code, :text],
      6..13 => [:date, date: [format: "MMDDYYYY"]],
      14..17 => [:time, time: [format: "HHMM"]],
      18..23 => [:file_id, :integer],
      24..43 => [:file_name, :text]
    }
  end

  defp format(line_number, total_lines, _line) when line_number == total_lines do
    %{
      1..5 => [:type_code, :text],
      6..13 => [:date, date: [format: "MMDDYYYY"]],
      14..17 => [:time, time: [format: "HHMM"]],
      18..23 => [:file_id, :integer],
      24..43 => [:file_name, :text],
      44..83 => [:recipient_key, :text],
      84..90 => [:record_count, :integer]
    }
  end

  defp format(_line_number, _total_lines, line) do
    line |> String.slice(43..44) |> detail_record_format
  end

  defp detail_record_format("00") do
    %{
      1..10 => [:amex_payee_number, :integer],
      11..20 => [:amex_sort_field_1, :text],
      21..30 => [:amex_sort_field_2, :text],
      31..34 => [:payment_year, :integer],
      35..42 => [:payment_number, :text],
      43..43 => [:record_type_code, :text],
      44..45 => [:type_code, :text],
      46..52 => [:payment_date, :julian_date],
      53..63 => [:payment_amount, overpunch: [decimals: 2]],
      64..72 => [:debit_balance_amount, overpunch: [decimals: 2]],
      73..81 => [:aba_bank_number, :integer],
      82..98 => [:se_dda_number, integer: [trim: true]]
    }
  end

  defp detail_record_format("10") do
    %{
      1..10 => [:amex_payee_number, :integer],
      11..20 => [:amex_se_number, :integer],
      21..30 => [:se_unit_number, :text],
      31..34 => [:payment_year, :integer],
      35..42 => [:payment_number, :text],
      43..43 => [:record_type_code, :text],
      44..45 => [:type_code, :text],
      46..52 => [:se_business_date, :julian_date],
      53..59 => [:amex_process_date, :julian_date],
      60..65 => [:soc_invoice_number, :integer],
      66..76 => [:soc_amount, overpunch: [decimals: 2]],
      77..85 => [:discount_amount, overpunch: [decimals: 2]],
      86..92 => [:service_fee_amount, overpunch: [decimals: 2]],
      100..110 => [:net_soc_amount, overpunch: [decimals: 2]],
      111..115 => [:discount_rate, :integer],
      116..120 => [:service_fee_rate, :integer],
      142..152 => [:amex_gross_amount, overpunch: [decimals: 2]],
      153..157 => [:amex_roc_count, :overpunch],
      158..166 => [:tracking_id, :integer],
      167..167 => [:cpc_indicator, :text],
      183..189 => [:amex_ro_count_poa, :overpunch]
    }
  end

  defp detail_record_format("11") do
    %{
      1..10 => [:amex_payee_number, :integer],
      11..20 => [:amex_se_number, :integer],
      44..45 => [:type_code, :text]
    }
  end

  defp detail_record_format("20") do
    %{
      44..45 => [:type_code, :text]
    }
  end
end
