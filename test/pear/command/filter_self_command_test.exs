defmodule Pear.Command.FilterSelfCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.FilterSelfCommand

  describe "FilterSelfCommand.accept?/1" do
    test "accepts reaction_added events" do
      assert FilterSelfCommand.accept? %{type: "reaction_added"}
    end

    test "accepts reaction_removed events" do
      assert FilterSelfCommand.accept? %{type: "reaction_removed"}
    end
  end

  describe "FilterSelfCommand.execute/2" do
    test "stops execution when self" do
      assert FilterSelfCommand.execute(%{user: "me"}, %{me: %{id: "me"}}) == :halt
    end

    test "continues execution when not self" do
      assert FilterSelfCommand.execute(%{user: "notme"}, %{me: %{id: "me"}}) == :cont
    end
  end
end
