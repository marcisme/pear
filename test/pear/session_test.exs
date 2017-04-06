defmodule Pear.SessionTest do
  use ExUnit.Case, async: true
  alias Pear.Session

  describe "Session.initialize/1" do
    test "creates new sessions" do
      assert {:ok, pid} = Session.initialize(%{channel: "1", ts: "2.3"})
      assert is_pid(pid)
      assert {:ok, pid} = Session.initialize(%{channel: "1", ts: "2.3"})
      assert is_pid(pid)
    end

    test "reinitializes existing sessions" do
      message = %{channel: "1", ts: "2.3"}
      Session.initialize(message)
      Session.add(message, "m1")
      Session.initialize(message)
      assert Session.user_ids(message) == []
    end
  end

  describe "Session.add/2" do
    test "adds user ids" do
      message = %{channel: "1", ts: "2.3"}
      Session.initialize(message)
      assert Session.user_ids(message) == []
      assert :ok = Session.add(message, "u1")
      assert Session.user_ids(message) == ["u1"]
    end

    test "handles noproc" do
      assert :nosession = Session.add(%{channel: "1", ts: "2.3"}, "_")
    end
  end

  describe "Session.remove/2" do
    test "removes user ids" do
      message = %{channel: "1", ts: "2.3"}
      Session.initialize(message)
      Session.add(message, "u1")
      assert :ok = Session.remove(message, "u1")
      assert Session.user_ids(message) == []
    end

    test "handles noproc" do
      assert :nosession = Session.remove(%{channel: "1", ts: "2.3"}, "_")
    end
  end

  describe "Session.user_ids/1" do
    test "handles noproc" do
      assert :nosession = Session.user_ids(%{channel: "1", ts: "2.3"})
    end
  end
end
