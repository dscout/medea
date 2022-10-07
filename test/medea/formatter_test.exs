defmodule Medea.FormatterTest do
  use ExUnit.Case, async: true

  use ExUnitProperties

  alias Medea.Formatter

  @datetime {{2022, 10, 06}, {16, 38, 00, 120}}

  defp format(level, message, time, metadata \\ []) do
    level
    |> Formatter.format(message, time, metadata)
    |> IO.iodata_to_binary()
    |> Jason.decode!()
  end

  describe "format/4" do
    property "encoding any messages as json iodata" do
      check all level <- level(), time <- datetime(), message <- message() do
        decoded = format(level, message, time)

        assert %{"level" => _, "time" => _, "message" => _} = decoded
      end
    end

    test "formatting log datetimes" do
      assert %{"time" => "2022-10-06T16:38:00.000"} = format(:info, "boop", @datetime)
    end

    test "formatting log metadata" do
      metadata = [user_id: 1, admin: true, thing: {:a, :b}]

      assert %{"metadata" => meta} = format(:info, "boop", @datetime, metadata)
      assert %{"user_id" => 1, "admin" => true, "thing" => ["a", "b"]} = meta
    end

    test "reporting logging errors" do
      assert %{"error" => error} = format(:info, {:error, :broken}, @datetime)

      assert error =~ "could not log '{:error, :broken}'"
    end
  end

  defp level, do: one_of([:alert, :error, :warning, :notice])

  defp message, do: string(:ascii)

  defp datetime do
    gen all year <- integer(1977..2022),
            month <- integer(1..12),
            day <- integer(1..28),
            hour <- integer(0..23),
            minute <- integer(0..59),
            second <- integer(0..59),
            ms <- integer(1..9999) do
      {{year, month, day}, {hour, minute, second, ms}}
    end
  end
end
