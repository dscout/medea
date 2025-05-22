defmodule Medea.Utils do
  @moduledoc false

  alias Jason.Encoder

  for {keypath, {m, f, a}} <- Application.compile_env(:medea, :formatters, %{}) do
    def clean(unquote(keypath), value) do
      apply(unquote(m), unquote(f), [unquote(keypath), value] ++ unquote(a))
    end
  end

  def clean(_keypath, %Date{} = date), do: date
  def clean(_keypath, %DateTime{} = datetime), do: datetime
  def clean(_keypath, %NaiveDateTime{} = naive), do: naive
  def clean(_keypath, %Time{} = time), do: time

  # Structs should implement Jason.Encoder
  def clean(keypath, %module{} = struct) do
    if Encoder.Any == Encoder.impl_for(struct) or
         module in Application.get_env(:medea, :except, []) do
      clean_struct(keypath, struct)
    else
      struct!(struct, clean_struct(keypath, struct))
    end
  end

  def clean(keypath, map) when is_map(map) do
    for {key, val} <- map, into: %{} do
      {clean_key(key), clean(keypath ++ [key], val)}
    end
  end

  def clean(keypath, list) when is_list(list) do
    cond do
      List.improper?(list) -> clean(keypath, convert_to_proper_list(list, []))
      Keyword.keyword?(list) -> clean(keypath, Map.new(list))
      true -> Enum.map(list, &clean(keypath, &1))
    end
  end

  def clean(keypath, tuple) when is_tuple(tuple) do
    clean(keypath, Tuple.to_list(tuple))
  end

  def clean(_keypath, binary) when is_binary(binary), do: Logger.Formatter.prune(binary)
  def clean(_keypath, term) when is_pid(term) or is_reference(term), do: inspect(term)
  def clean(_keypath, term) when is_port(term) or is_function(term), do: inspect(term)
  def clean(_keypath, term), do: term

  defp clean_struct(key, struct) do
    clean(key, Map.from_struct(struct))
  end

  defp convert_to_proper_list([], acc), do: Enum.reverse(acc)

  defp convert_to_proper_list([head | tail], acc) when is_list(tail) do
    convert_to_proper_list(tail, [head | acc])
  end

  defp convert_to_proper_list([head | tail], acc) do
    convert_to_proper_list([tail], [head | acc])
  end

  defp clean_key(key) when is_atom(key) or is_binary(key), do: key
  defp clean_key(key), do: inspect(key)
end
