defmodule Pear.SessionTest do
  use ExUnit.Case, async: true

  setup do
    name =
      %{channel: "C1234567890", ts: "1234567890.123456"}
      |> Pear.Session.name
    {:ok, _} = Pear.Session.start_link(name)
    {:ok, name: name}
  end

  test "stores user ids", %{name: name} do
    assert Pear.Session.get(name) == []

    Pear.Session.push(name, "U1234567890")
    assert Pear.Session.get(name) == ["U1234567890"]
  end

  test "deletes user ids", %{name: name} do
    Pear.Session.push(name, "U1234567890")

    Pear.Session.delete(name, "U1234567890")
    assert Pear.Session.get(name) == []
  end
end
