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
      assert {:web, :post_and_react, ["channel", "Bring out your pears!", "pear"]} =
        RandomPairCommand.execute(%{channel: "channel", ts: "", text: "a pair me b"}, nil)
    end

    test "continues execution when message does not contain 'pair me'" do
      assert :cont = RandomPairCommand.execute(%{text: "nope"}, nil)
    end
  end
end
