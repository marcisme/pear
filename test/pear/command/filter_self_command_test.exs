defmodule Pear.Command.FilterSelfCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.FilterSelfCommand

  describe "FilterSelfCommand.accept?/1" do
    test "accepts reaction_added messages" do
      assert FilterSelfCommand.accept? "reaction_added"
    end

    test "accepts reaction_removed messages" do
      assert FilterSelfCommand.accept? "reaction_removed"
    end
  end

  describe "FilterSelfCommand.execute/2" do
    test "stops execution when self" do
      assert :halt = FilterSelfCommand.execute(%{user: "me"}, %{me: %{id: "me"}})
    end

    test "continues execution when not self" do
      assert :cont = FilterSelfCommand.execute(%{user: "notme"}, %{me: %{id: "me"}})
    end
  end
end