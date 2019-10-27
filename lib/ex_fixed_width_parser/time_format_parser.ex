defmodule ExFixedWidthParser.TimeFormatParser do
  def parse(nil), do: :error
  def parse(format) when is_bitstring(format) do
    with [{hour_index, hour_length}] <- Regex.run(~r/H{1,2}/, format, return: :index),
         [{minute_index, minute_length}] <- Regex.run(~r/M{1,2}/, format, return: :index)
    do
      case Regex.run(~r/S{1,2}/, format, return: :index) do
        [{second_index, second_length}] ->
          {
            :ok,
            [
              hour: (hour_index)..(hour_index + hour_length - 1),
              minute: (minute_index)..(minute_index + minute_length - 1),
              second: (second_index)..(second_index + second_length - 1),
            ]
          }
        _ ->
          {
            :ok,
            [
              hour: (hour_index)..(hour_index + hour_length - 1),
              minute: (minute_index)..(minute_index + minute_length - 1),
            ]
          }
      end
    else
      _ -> :error
    end
  end
end
