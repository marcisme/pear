defmodule Pear.Command.FilterNonDirectCommandTest do
  use ExUnit.Case, async: true
  alias Pear.Command.FilterNonDirectCommand

  describe "FilterNonDirectCommand.accept?/1" do
    test "accepts event events" do
      assert FilterNonDirectCommand.accept? "message"
    end
  end

  describe "FilterNonDirectCommand.execute/2" do
    test "stops execution when not directly addressed" do
      assert FilterNonDirectCommand.execute(%{text: "whatevs"}, %{me: %{id: "id"}}) == :halt
    end

    test "continues execution when directly addressed" do
      assert FilterNonDirectCommand.execute(%{text: "a <@id> b"}, %{me: %{id: "id"}}) == :cont
    end
  end
end
