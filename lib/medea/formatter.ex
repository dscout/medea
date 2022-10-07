defmodule Medea.Formatter do
  @moduledoc """
  A formatter for JSON logs.
  """

  alias Medea.Utils

  @type time :: Logger.Formatter.time()

  @doc """
  Format messages into structured JSON logs.
  """
  @spec format(Logger.level(), Logger.message(), time(), keyword()) :: IO.chardata()
  def format(level, message, time, metadata) do
    formatted =
      binding()
      |> Enum.map(fn {key, val} -> [?", to_string(key), ?", ?:, format(key, val)] end)
      |> Enum.intersperse(?,)

    [?{, formatted, ?}, ?\n]
  rescue
    exception ->
      reason = Exception.format_banner(:error, exception)

      [~s({"error":"could not log '), inspect(message), "' because: ", reason, ~s("})]
  end

  defp format(:level, level), do: Jason.encode_to_iodata!(level)

  defp format(:message, message) when is_list(message), do: message
  defp format(:message, message), do: Jason.encode_to_iodata!(message)

  defp format(:metadata, metadata) do
    metadata
    |> Utils.clean()
    |> Jason.encode_to_iodata!()
  end

  defp format(:time, {date, {h, m, s, ms}}) do
    {date, {h, m, s}}
    |> NaiveDateTime.from_erl!({ms, 3})
    |> Jason.encode_to_iodata!()
  end
end
