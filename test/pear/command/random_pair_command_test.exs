defmodule Pear.Command.RandomPairCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RandomPairCommand
  import Pear.TestHelpers

  describe "RandomPairCommand.accept?/1" do
    test "accepts message messages" do
      assert RandomPairCommand.accept? "message"
    end
  end

  describe "RandomPairCommand.execute/2 when message contains 'pair me'" do
    test "returns a :post_and_react command" do
      assert RandomPairCommand.execute(%{channel: c("1"), ts: "2.3", text: "a pair me b"}, nil) ==
        {:web, :post_and_react, [c("1"), "Bring out your pears!", "pear"]}
    end

    test "initializes a session" do
      message = %{channel: c("1"), ts: "2.3", text: "a pair me b"}

      RandomPairCommand.execute(message, nil)

      refute Pear.Session.user_ids(message) == :nosession
    end
  end

  describe "RandomPairCommand.execute/2 when message does not contain 'pair me'" do
    test "continues execution" do
      assert RandomPairCommand.execute(%{text: "nope"}, nil) == :cont
    end
  end
end
