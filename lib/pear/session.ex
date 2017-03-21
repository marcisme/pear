defmodule Pear.Session do
  def start_link(message) do
    Agent.start_link(fn -> [] end, name: via_name(message))
  end

  def lookup(%{channel: channel, ts: ts}) do
    Registry.lookup(__MODULE__, {channel, ts})
  end

  def user_ids(message) do
    message
    |> via_name
    |> Agent.get(fn list -> list end)
  end

  def add(message, user_id) do
    message
    |> via_name
    |> Agent.update(fn list -> [user_id | list] end)
  end

  def remove(message, user_id) do
    message
    |> via_name
    |> Agent.update(&List.delete(&1, user_id))
  end

  defp via_name(%{channel: channel, ts: ts}) do
    {:via, Registry, {__MODULE__, {channel, ts}}}
  end
end
