defmodule MedeaTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  require Logger

  setup_all do
    Logger.add_translator({Medea.Translator, :translate})
  end

  defp capture_message(message) do
    capture_log(fn -> Logger.info(message) end)
  end

  test "logging structured messages with arbitrary terms" do
    assert capture_message("raw string") =~ ~s("message":"raw string")
    assert capture_message(%{source: "truth"}) =~ ~s({"source":"truth"})
    assert capture_message(source: :truth) =~ ~s({"source":"truth"})
    assert capture_message(source: %{is: true}) =~ ~s({"source":{"is":true}})
    assert capture_message(time: ~T[10:00:00]) =~ ~s({"time":"10:00:00"})
    assert capture_message(date: ~D[2022-10-06]) =~ ~s({"date":"2022-10-06"})
    assert capture_message(pid: self()) =~ ~s({"pid":"#PID<0)
    assert capture_message(ref: make_ref()) =~ ~s({"ref":"#Reference<0)
  end

  test "logging fall-through translated messages" do
    {:ok, pid} =
      Task.start(fn ->
        receive do
          :go -> raise "oops"
        end
      end)

    logged =
      capture_log(fn ->
        ref = Process.monitor(pid)

        send(pid, :go)

        receive do: ({:DOWN, ^ref, _, _, _} -> :ok)
      end)

    assert logged =~ ~s("message":"Task #PID)
  end
end
