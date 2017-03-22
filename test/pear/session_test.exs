defmodule Pear.SessionTest do
  use ExUnit.Case, async: true

  setup do
    message = %{channel: "1", ts: "2.3"}
    {:ok, _} = Pear.Session.initialize(message)
    {:ok, message: message}
  end

  test "creates new sessions" do
    assert {:ok, pid} = Pear.Session.initialize(%{channel: "1", ts: "2.3"})
    assert is_pid(pid)
    assert {:ok, pid} = Pear.Session.initialize(%{channel: "1", ts: "2.3"})
    assert is_pid(pid)
  end

  test "reinitializes existing sessions" do
    message = %{channel: "1", ts: "2.3"}
    Pear.Session.initialize(message)
    Pear.Session.add(message, "4")
    Pear.Session.initialize(message)
    assert Pear.Session.user_ids(message) == []
  end

  test "adds user ids", %{message: message} do
    assert Pear.Session.user_ids(message) == []
    Pear.Session.add(message, "U1234567890")
    assert Pear.Session.user_ids(message) == ["U1234567890"]
  end

  test "removes user ids", %{message: message} do
    Pear.Session.add(message, "U1234567890")
    Pear.Session.remove(message, "U1234567890")
    assert Pear.Session.user_ids(message) == []
  end

  test "ignores unknown messages" do
    Pear.Session.add(%{channel: "_", ts: "_"}, "_")
    Pear.Session.remove(%{channel: "_", ts: "_"}, "_")
  end
end
