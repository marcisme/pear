defmodule Pear.AcceptanceTest do
  use ExUnit.Case, async: false
  alias Pear.TestBot

  @moduletag :capture_log
  @moduletag :acceptance
  @test_api_token Application.fetch_env!(:pear, :test_api_token)
  @test_channel Application.fetch_env!(:pear, :test_channel)

  describe "random pairing sessions" do
    test "happy path" do
      {:ok, _} = Slack.Bot.start_link(Pear.Bot, [], Application.fetch_env!(:slack, :api_token))
      {:ok, test_bot} = TestBot.start_link(@test_api_token)

      TestBot.send_test_message(test_bot, "@pear pair me", @test_channel)
      eventually(fn ->
        assert TestBot.has_message(test_bot, "Bring out your pears!")
      end)

      TestBot.react(test_bot, "Bring out your pears!", "microscope")

      TestBot.send_test_message(test_bot, "@pear go", @test_channel)
      eventually(fn ->
        assert TestBot.has_message(test_bot, "Here are your pairs: @test1")
      end)
    end
  end

  defp eventually(timeout \\ 1_000, delay \\ 100, assertion) do
    start = :os.system_time(:millisecond)
    Enum.reduce_while(1..100, 0, fn _, acc ->
      try do
        assertion.()
        {:halt, acc}
      rescue
        e ->
          now = :os.system_time(:millisecond)
          cond do
            now - start < timeout ->
              Process.sleep(delay)
              {:cont, acc}
            true ->
              raise e
          end
      end
    end)
  end
end
