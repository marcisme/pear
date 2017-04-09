defmodule Pear.Command.RandomPairGoCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RandomPairGoCommand
  import Pear.TestHelpers

  describe "RandomPairGoCommand.accept?/1" do
    test "accepts message messages" do
      assert RandomPairGoCommand.accept? "message"
    end
  end

  describe "RandomPairGoCommand.execute/2 when message contains 'go'" do
    test "returns a command when the session exists" do
      message = %{channel: c("1"), ts: "2.3", text: "a go b"}
      Pear.Session.initialize(message)
      Pear.Session.add(message, "u1")

      assert RandomPairGoCommand.execute(message, nil) ==
        {:rtm, :send, [c("1"), "Here are your pairs: <@u1>"]}
    end

    test "halts execution when the session does not exist" do
      message = %{channel: c("1"), ts: "2.3", text: "a go b"}

      assert RandomPairGoCommand.execute(message, nil) == :halt
    end
  end

  describe "RandomPairGoCommand.execute/2 when message does not contain 'go'" do
    test "continues execution when message does not contain 'go'" do
      assert RandomPairGoCommand.execute(%{text: "nope"}, nil) == :cont
    end
  end
end
