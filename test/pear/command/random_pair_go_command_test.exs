defmodule Pear.Command.RandomPairGoCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RandomPairGoCommand
  import Pear.TestHelpers

  describe "RandomPairGoCommand.accept?/1" do
    test "accepts message events" do
      assert RandomPairGoCommand.accept? %{type: "message"}
    end
  end

  describe "RandomPairGoCommand.execute/2 when event contains 'go'" do
    test "returns a command when the session exists" do
      channel = c("1")
      event = %{channel: channel, ts: "2.3", text: "a go b"}
      Pear.Session.initialize(event)
      Pear.Session.add(event, "u1")
      Pear.Session.add(event, "u2")
      Pear.Session.add(event, "u3")

      assert {:rtm, :send, [^channel, text]} = RandomPairGoCommand.execute(event, nil)
      assert Regex.match?(~r/Here are your pairs: \[<@u\d>, <@u\d>\], \[<@u\d>\]/, text)
    end

    test "halts execution when the session does not exist" do
      event = %{channel: c("1"), ts: "2.3", text: "a go b"}

      assert RandomPairGoCommand.execute(event, nil) == :halt
    end
  end

  describe "RandomPairGoCommand.execute/2 when event does not contain 'go'" do
    test "continues execution when event does not contain 'go'" do
      assert RandomPairGoCommand.execute(%{text: "nope"}, nil) == :cont
    end
  end
end
