defmodule ExFixedWidthParser.DateFormatParser do
  def parse(nil), do: :error
  def parse(format) when is_bitstring(format) do
    with [{year_index, year_length}] <- Regex.run(~r/Y{1,4}/, format, return: :index),
         [{month_index, month_length}] <- Regex.run(~r/M{1,2}/, format, return: :index),
         [{day_index, day_length}] <- Regex.run(~r/D{1,2}/, format, return: :index)
    do
      {
        :ok,
        [
          year: (year_index)..(year_index + year_length - 1),
          month: (month_index)..(month_index + month_length - 1),
          day: (day_index)..(day_index + day_length - 1),
        ]
      }
    else
      _ -> :error
    end
  end
end
