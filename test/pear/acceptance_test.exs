defmodule Pear.AcceptanceTest do
  use ExUnit.Case, async: false
  alias Pear.TestBot
  import Pear.Assertions

  @moduletag :capture_log
  @moduletag :acceptance
  @test_api_token Application.fetch_env!(:pear, :test_api_token)
  @test_channel Application.fetch_env!(:pear, :test_channel)

  describe "random pairing sessions" do
    test "happy path" do
      {:ok, _} = Slack.Bot.start_link(Pear.Bot, [], Application.fetch_env!(:slack, :api_token))
      {:ok, test_bot} = TestBot.start_link(@test_api_token)

      TestBot.send_test_message(test_bot, "@pear pair me", @test_channel)
      eventually do
        assert TestBot.has_message(test_bot, "Bring out your pears!")
      end

      TestBot.react(test_bot, "Bring out your pears!", "microscope")

      TestBot.send_test_message(test_bot, "@pear go", @test_channel)
      eventually do
        assert TestBot.has_message(test_bot, "Here are your pairs: @test1")
      end
    end
  end
end

