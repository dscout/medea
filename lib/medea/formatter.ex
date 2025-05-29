defmodule Medea.Formatter do
  @moduledoc """
  A formatter for JSON logs.
  """

  alias Medea.Utils

  @type time :: Logger.Formatter.date_time_ms()

  @doc """
  Format messages into structured JSON logs.
  """
  @spec format(Logger.level(), Logger.message(), time(), keyword()) :: IO.chardata()
  def format(level, message, time, metadata) do
    formatted =
      binding()
      |> Enum.map(fn {key, val} -> [to_key(key), to_val(key, val)] end)
      |> Enum.intersperse(?,)

    [?{, formatted, ?}, ?\n]
  rescue
    exception ->
      reason = Exception.format_banner(:error, exception)

      [~s({"error":"could not log '), inspect(message), "' because: ", reason, ~s("})]
  end

  for key <- ~w(level message time metadata)a do
    defp to_key(unquote(key)), do: [?", unquote(to_string(key)), ?", ?:]
  end

  defp to_val(:level, level), do: Jason.encode_to_iodata!(level)

  defp to_val(:message, ["{\"" | _] = message), do: message
  defp to_val(:message, message) when is_list(message), do: [?", message, ?"]
  defp to_val(:message, message), do: Jason.encode_to_iodata!(message)

  defp to_val(:metadata, metadata) do
    [:metadata]
    |> Utils.clean(metadata)
    |> Jason.encode_to_iodata!()
  end

  defp to_val(:time, {date, {h, m, s, ms}}) do
    {date, {h, m, s}}
    |> NaiveDateTime.from_erl!({ms, 3})
    |> Jason.encode_to_iodata!()
  end
end
