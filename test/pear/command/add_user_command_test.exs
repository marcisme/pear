defmodule Pear.Command.AddUserCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.AddUserCommand

  describe "AddUserCommand.accept?/1" do
    test "accepts reaction_added messages" do
      assert AddUserCommand.accept? "reaction_added"
    end
  end

  describe "AddUserCommand.execute/2" do
    test "returns a :post_and_react command" do
      message = %{channel: "1", ts: "2.3"}
      Pear.Session.initialize(message)
      AddUserCommand.execute(%{item: message, user: "u1"}, nil)
      assert Pear.Session.user_ids(message) == ["u1"]
    end

    test "halts execution" do
      message = %{channel: "1", ts: "2.3"}
      # Pear.Session.initialize(message)
      # TODO: handle out of order events?
      assert AddUserCommand.execute(%{item: message, user: "u1"}, nil) == :halt
    end
  end
end
