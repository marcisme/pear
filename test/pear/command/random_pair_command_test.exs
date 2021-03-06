defmodule Pear.Command.RandomPairCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RandomPairCommand
  import Pear.TestHelpers

  describe "RandomPairCommand.accept?/1" do
    test "accepts message events" do
      assert RandomPairCommand.accept? %{type: "message"}
    end
  end

  describe "RandomPairCommand.help/0" do
    test "is helpful" do
      assert RandomPairCommand.help == "I can help you organize a random pairing session if you tell me to \"pair\"."
    end
  end

  describe "RandomPairCommand.execute/2 when event contains 'pair'" do
    test "returns a :post_and_react command" do
      assert RandomPairCommand.execute(%{channel: c("1"), ts: "2.3", text: "a pair b"}, nil) ==
        {:web, :post_and_react, [c("1"), "Random pairing time!\nAdd reactions to this message to participate, and tell me to \"go\" when you're ready.", "pear"]}
    end

    test "initializes a session" do
      event = %{channel: c("1"), ts: "2.3", text: "a pair b"}

      RandomPairCommand.execute(event, nil)

      refute Pear.Session.user_ids(event) == :nosession
    end
  end

  describe "RandomPairCommand.execute/2 when event contains ':pear:'" do
    test "returns a :post_and_react command when ':pear:' is embedded" do
      assert RandomPairCommand.execute(%{channel: c("1"), ts: "2.3", text: "a:pear:b"}, nil) ==
        {:web, :post_and_react, [c("1"), "Random pairing time!\nAdd reactions to this message to participate, and tell me to \"go\" when you're ready.", "pear"]}
    end

    test "returns a :post_and_react command when ':pear:' is not embedded" do
      assert RandomPairCommand.execute(%{channel: c("1"), ts: "2.3", text: ":pear:"}, nil) ==
        {:web, :post_and_react, [c("1"), "Random pairing time!\nAdd reactions to this message to participate, and tell me to \"go\" when you're ready.", "pear"]}
    end
  end

  describe "RandomPairCommand.execute/2 when event does not contain 'pair'" do
    test "continues execution when no 'pair'" do
      assert RandomPairCommand.execute(%{text: "nope"}, nil) == :cont
    end

    test "continues execution when no explicit 'pair'" do
      assert RandomPairCommand.execute(%{text: "apairb"}, nil) == :cont
    end
  end
end
