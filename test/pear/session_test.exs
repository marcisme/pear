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
      event = %{channel: "1", ts: "2.3"}
      Session.initialize(event)
      Session.add(event, "m1")
      Session.initialize(event)
      assert Session.user_ids(event) == []
    end
  end

  describe "Session.add/2" do
    test "adds user ids" do
      event = %{channel: "1", ts: "2.3"}
      Session.initialize(event)
      assert Session.user_ids(event) == []
      assert :ok = Session.add(event, "u1")
      assert Session.user_ids(event) == ["u1"]
    end

    test "adds user ids only once" do
      event = %{channel: "1", ts: "2.3"}
      Session.initialize(event)
      assert Session.user_ids(event) == []
      assert :ok = Session.add(event, "u1")
      assert :ok = Session.add(event, "u1")
      assert Session.user_ids(event) == ["u1"]
    end

    test "handles noproc" do
      assert :nosession = Session.add(%{channel: "1", ts: "2.3"}, "_")
    end
  end

  describe "Session.remove/2" do
    test "removes user ids" do
      event = %{channel: "1", ts: "2.3"}
      Session.initialize(event)
      Session.add(event, "u1")
      assert :ok = Session.remove(event, "u1")
      assert Session.user_ids(event) == []
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
