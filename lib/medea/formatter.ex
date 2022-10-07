defmodule Medea.Formatter do
  @moduledoc """
  A formatter for JSON logs.
  """

  import Jason.Helpers, only: [json_map: 1]

  alias Medea.Utils

  @type time :: Logger.Formatter.time()

  @doc """
  Format messages into structured JSON logs.
  """
  @spec format(Logger.level(), Logger.message(), time(), keyword()) :: IO.chardata()
  def format(level, message, time, metadata) do
    [level: level, time: format_time(time), message: message, metadata: Utils.clean(metadata)]
    |> json_map()
    |> Jason.encode_to_iodata!()
  rescue
    exception ->
      reason = Exception.format_banner(:error, exception)

      [~s({"error":"could not log '), inspect(message), "' because: ", reason, ~s("})]
  end

  defp format_time({date, {h, m, s, ms}}) do
    {date, {h, m, s}}
    |> NaiveDateTime.from_erl!({ms, 3})
    |> NaiveDateTime.to_string()
  end
end
