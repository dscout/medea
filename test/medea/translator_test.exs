defmodule Medea.TranslatorTest do
  use ExUnit.Case, async: true

  use ExUnitProperties

  alias Medea.Translator

  describe "translate/4" do
    property "all terms are safely encoded to iodata" do
      check all message <- message() do
        assert {:ok, iodata} = Translator.translate(:info, :info, :report, {:logger, message})

        assert is_binary(iodata)
      end
    end

    test "all non-logger formats or reports are ignored" do
      assert :none = Translator.translate(:info, :info, :report, {:not, :from, :logger})
    end
  end

  defp message do
    one_of([
      atom(:alphanumeric),
      binary(),
      tuple({key(), val()}),
      map_of(key(), val()),
      keyword_of(val())
    ])
  end

  defp key, do: one_of([atom(:alphanumeric), string(:ascii)])

  defp val, do: one_of([atom(:alphanumeric), map_of(key(), key())])
end
