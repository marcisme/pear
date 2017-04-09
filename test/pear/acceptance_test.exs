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

      TestBot.send_test_message(test_bot, "and so it begins...", @test_channel)

      TestBot.send_test_message(test_bot, "@pear pair me", @test_channel)
      eventually do
        assert TestBot.has_message(test_bot, "Bring out your pears!")
      end

      TestBot.react(test_bot, "Bring out your pears!", "microscope")

      TestBot.send_test_message(test_bot, "@pear go", @test_channel)
      eventually do
        assert TestBot.has_message_starting_with(test_bot, "Here are your pairs: ")
      end

      # When tests are run close together, it's possible to be resent
      # events from a previous run. This count confirms that we've only
      # seen the number of messages that we expect from this run.
      # A failure here means either the expected count is wrong, or the
      # message filtering done by the TestBot has a bug.
      # The expected message count should most likely be equal to the
      # number of `eventually` blocks above.
      assert TestBot.test_messages(test_bot) |> Enum.count == 2
    end
  end
end

