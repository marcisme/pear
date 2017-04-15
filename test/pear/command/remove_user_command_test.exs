defmodule Pear.Command.RemoveUserCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.RemoveUserCommand
  import Pear.TestHelpers

  describe "RemoveUserCommand.accept?/1" do
    test "accepts reaction_added events" do
      assert RemoveUserCommand.accept? %{type: "reaction_removed"}
    end
  end

  describe "RemoveUserCommand.execute/2" do
    test "returns a :post_and_react command" do
      event = %{channel: c("1"), ts: "2.3"}
      Pear.Session.initialize(event)
      Pear.Session.add(event, "u1")

      RemoveUserCommand.execute(%{item: event, user: "u1"}, nil)

      assert Pear.Session.user_ids(event) == []
    end

    test "halts execution" do
      event = %{channel: c("1"), ts: "2.3"}
      assert RemoveUserCommand.execute(%{item: event, user: "u1"}, nil) == :halt
    end
  end
end
