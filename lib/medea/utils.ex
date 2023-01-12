defmodule Medea.Utils do
  @moduledoc false

  alias Jason.Encoder

  def clean(%Date{} = date), do: date
  def clean(%DateTime{} = datetime), do: datetime
  def clean(%NaiveDateTime{} = naive), do: naive
  def clean(%Time{} = time), do: time

  # Structs should implement Jason.Encoder
  def clean(%_{} = struct) do
    if Encoder.Any != Encoder.impl_for(struct) do
      map = clean_struct(struct)
      struct!(struct, map)
    else
      clean_struct(struct)
    end
  end

  def clean(map) when is_map(map) do
    for {key, val} <- map, into: %{}, do: {clean_key(key), clean(val)}
  end

  def clean(list) when is_list(list) do
    if Keyword.keyword?(list) do
      list
      |> Map.new()
      |> clean()
    else
      for elem <- list, do: clean(elem)
    end
  end

  def clean(tuple) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> clean()
  end

  def clean(binary) when is_binary(binary), do: Logger.Formatter.prune(binary)
  def clean(term) when is_pid(term) or is_reference(term), do: inspect(term)
  def clean(term) when is_port(term) or is_function(term), do: inspect(term)
  def clean(term), do: term

  defp clean_key(key) when is_atom(key) or is_binary(key), do: key
  defp clean_key(key), do: inspect(key)

  defp clean_struct(struct) do
    struct
    |> Map.from_struct()
    |> clean()
  end
end
