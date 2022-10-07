defmodule Medea.Translator do
  @moduledoc """
  Translates structured log "reports" into encoded JSON iodata.
  """

  alias Medea.Utils

  @type kind :: :format | :report
  @type level :: Logger.level()
  @type report :: :logger.report()

  @type result ::
          {:ok, iodata(), keyword()}
          | {:ok, iodata()}
          | :skip
          | :none

  @doc """
  Translate a report into encoded JSON iodata or fall through to the default translator.
  """
  @spec translate(level(), level(), kind(), report()) :: result()
  def translate(_min, _level, :report, {:logger, message}) do
    encoded =
      message
      |> Utils.clean()
      |> Jason.encode!()

    {:ok, encoded}
  end

  def translate(_min_lev, _level, _kind, _message), do: :none
end
