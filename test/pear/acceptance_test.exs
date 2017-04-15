defmodule Pear.AcceptanceTest do
  use ExUnit.Case, async: false
  alias Pear.TestBot
  import Pear.Assertions

  @moduletag :acceptance

  @api_token Config.get(:slack, :api_token)
  @test_api_token Config.get(:pear, :test_api_token)
  @test_channel "#" <> Config.get(:pear, :test_channel)

  setup_all do
    {:ok, _} = Slack.Bot.start_link(Pear.Bot, [], @api_token)
    {:ok, test_bot} = TestBot.start_link(@test_api_token)
    TestBot.send_test_message(test_bot, "and so it begins...", @test_channel)
    %{test_bot: test_bot}
  end

  setup context do
    on_exit fn ->
      TestBot.reset(context.test_bot)
    end
    context
  end

  describe "random pairing sessions" do
    test "happy path", %{test_bot: test_bot} do
      TestBot.send_test_message(test_bot, "@pear pair me", @test_channel)
      eventually do
        assert TestBot.has_message_starting_with(test_bot, "Random pairing time!")
      end

      TestBot.react(test_bot, "Random pairing time!", "microscope")

      TestBot.send_test_message(test_bot, "@pear go", @test_channel)
      eventually do
        assert TestBot.has_message_starting_with(test_bot, "Here are your pairs: ")
      end

      # When tests are run close together, it's possible to be resent
      # events from a previous run. This count confirms that we've only
      # seen the number of messages that we expect from this run.
      # A failure here means either the expected count is wrong, or the
      # event filtering done by the TestBot has a bug.
      # The expected message count should most likely be equal to the
      # number of `eventually` blocks above.
      eventually do
        assert TestBot.test_messages(test_bot) |> Enum.count == 2
      end
    end
  end

  describe "help" do
    test "unknown command", %{test_bot: test_bot} do
      TestBot.send_test_message(test_bot, "@pear dafuq?", @test_channel)

      eventually do
        assert TestBot.has_message(test_bot, "I'm sorry, I don't know how to do that. Ask me for \"help\" to see what I respond to.")
      end
    end

    test "help command", %{test_bot: test_bot} do
      TestBot.send_test_message(test_bot, "@pear help", @test_channel)

      eventually do
        assert TestBot.has_message(test_bot, "I can help you organize a random pairing session if you tell me to \"pair\".")
      end
    end
  end
end

