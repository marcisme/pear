defmodule Pear.Command.AddUserCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.AddUserCommand
  import Pear.TestHelpers

  describe "AddUserCommand.accept?/1" do
    test "accepts reaction_added events" do
      assert AddUserCommand.accept? "reaction_added"
    end
  end

  describe "AddUserCommand.execute/2" do
    test "returns a :post_and_react command" do
      event = %{channel: c("1"), ts: "2.3"}
      Pear.Session.initialize(event)

      AddUserCommand.execute(%{item: event, user: "u1"}, nil)

      assert Pear.Session.user_ids(event) == ["u1"]
    end

    test "halts execution" do
      event = %{channel: c("1"), ts: "2.3"}
      assert AddUserCommand.execute(%{item: event, user: "u1"}, nil) == :halt
    end
  end
end
