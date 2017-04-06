defmodule Pear.Command.RandomPairGoCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RandomPairGoCommand

  describe "RandomPairGoCommand.accept?/1" do
    test "accepts message messages" do
      assert RandomPairGoCommand.accept? "message"
    end
  end

  describe "RandomPairGoCommand.execute/2" do
    # test "returns a command when message contains 'go'" do
    #   assert {:web, :send, ["channel", "Here are your pairs: @test"]} =
    #     RandomPairGoCommand.execute(%{channel: "channel", ts: "", text: "a go b"}, nil)
    # end

    test "continues execution when message does not contain 'pair me'" do
      assert :cont = RandomPairGoCommand.execute(%{text: "nope"}, nil)
    end
  end
end
