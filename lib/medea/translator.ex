defmodule Medea.Translator do
  @moduledoc """
  Translates structured log "reports" into encoded JSON iodata.
  """

  @behaviour Logger.Translator

  alias Medea.Utils

  @impl Logger.Translator
  def translate(_min, _level, :report, {:logger, message}) do
    encoded =
      []
      |> Utils.clean(message)
      |> Jason.encode_to_iodata!()

    {:ok, encoded}
  end

  def translate(_min_lev, _level, _kind, _message), do: :none
end
