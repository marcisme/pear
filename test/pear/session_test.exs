defmodule Pear.SessionTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, session} = Pear.Session.start_link
    {:ok, session: session}
  end

  test "stores user ids", %{session: session} do
    assert Pear.Session.get(session) == []

    Pear.Session.push(session, "U1234567890")
    assert Pear.Session.get(session) == ["U1234567890"]
  end

  test "deletes user ids", %{session: session} do
    Pear.Session.push(session, "U1234567890")

    Pear.Session.delete(session, "U1234567890")
    assert Pear.Session.get(session) == []
  end
end
