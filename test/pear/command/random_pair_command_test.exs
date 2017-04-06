defmodule Pear.Command.RandomPairCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RandomPairCommand

  describe "RandomPairCommand.accept?/1" do
    test "accepts message messages" do
      assert RandomPairCommand.accept? "message"
    end
  end

  describe "RandomPairCommand.execute/2" do
    test "returns a :post_and_react command when message contains 'pair me'" do
      assert {:web, :post_and_react, ["1", "Bring out your pears!", "pear"]} =
        RandomPairCommand.execute(%{channel: "1", ts: "2.3", text: "a pair me b"}, nil)
    end

    test "initializes a session when message contains 'pair me'" do
      message = %{channel: "1", ts: "2.3", text: "a pair me b"}
      RandomPairCommand.execute(message, nil)
      refute Pear.Session.user_ids(message) == :nosession
    end

    test "continues execution when message does not contain 'pair me'" do
      assert :cont = RandomPairCommand.execute(%{text: "nope"}, nil)
    end
  end
end
