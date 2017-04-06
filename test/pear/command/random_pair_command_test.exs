defmodule Pear.Command.RandomPairCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RandomPairCommand

  describe "RandomPairCommand.accept?/1" do
    test "accepts message messages" do
      assert RandomPairCommand.accept? "message"
    end
  end

  describe "RandomPairCommand.execute/2 when message contains 'pair me'" do
    test "returns a :post_and_react command" do
      assert {:web, :post_and_react, ["1", "Bring out your pears!", "pear"]} =
        RandomPairCommand.execute(%{channel: "1", ts: "2.3", text: "a pair me b"}, nil)
    end

    test "initializes a session" do
      message = %{channel: "1", ts: "2.3", text: "a pair me b"}
      RandomPairCommand.execute(message, nil)
      refute Pear.Session.user_ids(message) == :nosession
    end
  end

  describe "RandomPairCommand.execute/2 when message does not contain 'pair me'" do
    test "continues execution" do
      assert :cont = RandomPairCommand.execute(%{text: "nope"}, nil)
    end
  end
end
