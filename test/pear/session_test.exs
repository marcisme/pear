defmodule Pear.SessionTest do
  use ExUnit.Case, async: true

  setup do
    message = %{channel: "C1234567890", ts: "1234567890.123456"}
    {:ok, _} = Pear.Session.start_link(message)
    {:ok, message: message}
  end

  test "stores user ids", %{message: message} do
    assert Pear.Session.user_ids(message) == []

    Pear.Session.add(message, "U1234567890")
    assert Pear.Session.user_ids(message) == ["U1234567890"]
  end

  test "deletes user ids", %{message: message} do
    Pear.Session.add(message, "U1234567890")

    Pear.Session.remove(message, "U1234567890")
    assert Pear.Session.user_ids(message) == []
  end

  test "looks up session", %{message: message} do
    assert Pear.Session.lookup(message)
  end
end
