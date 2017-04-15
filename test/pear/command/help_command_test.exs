defmodule Pear.Command.HelpCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.HelpCommand
  import Pear.TestHelpers

  describe "HelpCommand.accept?/1" do
    test "accepts message events" do
      assert HelpCommand.accept? %{type: "message"}
    end
  end

  describe "HelpCommand.execute/2" do
    test "sends a message when nothing matches" do
      assert HelpCommand.execute(%{channel: c("1"), ts: "2.3", text: "dafuq?"}, nil) ==
        {:rtm, :send, [c("1"), "I'm sorry, I don't know how to do that. Ask me for \"help\" to see what I respond to."]}
    end

    test "sends a message when 'help' is part of another word" do
      assert HelpCommand.execute(%{channel: c("1"), ts: "2.3", text: "ahelpb"}, nil) ==
        {:rtm, :send, [c("1"), "I'm sorry, I don't know how to do that. Ask me for \"help\" to see what I respond to."]}
    end

    test "sends help when asked for 'help'" do
      assert HelpCommand.execute(%{channel: c("1"), ts: "2.3", text: "a help b"}, nil) == {:help, c("1")}
    end
  end
end
