defmodule Medea.TranslatorTest do
  use ExUnit.Case, async: true

  use ExUnitProperties

  alias Medea.Translator

  require Protocol

  defmodule Struct do
    @moduledoc false

    defstruct id: 1,
              private: %{data: :hidden},
              public: %{data: :visible}
  end

  describe "translate/4" do
    property "all terms are safely encoded to iodata" do
      check all message <- message() do
        assert {:ok, iodata} = Translator.translate(:info, :info, :report, {:logger, message})

        assert is_list(iodata) or is_binary(iodata)
      end
    end

    test "custom implementations of Jason.Encoder are respected" do
      # Private data is exposed
      assert {:ok, iodata} = Translator.translate(:info, :info, :report, {:logger, %Struct{}})

      assert ~s({"id":1,"private":{"data":"hidden"},"public":{"data":"visible"}}) ==
               IO.chardata_to_string(iodata)

      # Private data is redacted
      Protocol.derive(Jason.Encoder, Struct, except: [:private])

      assert {:ok, iodata} = Translator.translate(:info, :info, :report, {:logger, %Struct{}})
      assert ~s({"id":1,"public":{"data":"visible"}}) == IO.chardata_to_string(iodata)
    end

    test "all non-logger formats or reports are ignored" do
      assert :none = Translator.translate(:info, :info, :report, {:not, :from, :logger})
    end
  end

  defp message do
    one_of([
      random(),
      struct()
    ])
  end

  defp random do
    one_of([
      atom(:alphanumeric),
      binary(),
      tuple({key(), val()}),
      map_of(key(), val()),
      keyword_of(val()),
      list_of(one_of([tuple({key(), val()}), atom(:alphanumeric)])),
      map_of(list_of(atom(:alphanumeric)), val())
    ])
  end

  defp key, do: one_of([atom(:alphanumeric), string(:ascii)])

  defp val, do: one_of([atom(:alphanumeric), map_of(key(), key())])

  defp struct, do: map(random(), &%Struct{private: &1, public: &1})
end
