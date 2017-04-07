defmodule Pear.Command.RemoveUserCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RemoveUserCommand
  import Pear.TestHelpers

  describe "RemoveUserCommand.accept?/1" do
    test "accepts reaction_added messages" do
      assert RemoveUserCommand.accept? "reaction_removed"
    end
  end

  describe "RemoveUserCommand.execute/2" do
    test "returns a :post_and_react command" do
      message = %{channel: c("1"), ts: "2.3"}
      Pear.Session.initialize(message)
      Pear.Session.add(message, "u1")

      RemoveUserCommand.execute(%{item: message, user: "u1"}, nil)

      assert Pear.Session.user_ids(message) == []
    end

    test "halts execution" do
      message = %{channel: c("1"), ts: "2.3"}
      assert RemoveUserCommand.execute(%{item: message, user: "u1"}, nil) == :halt
    end
  end
end
