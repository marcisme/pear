defmodule Pear.Session do
  def name(%{channel: channel, ts: ts}) do
    {:via, Registry, {__MODULE__, {channel, ts}}}
  end

  def start_link(name) do
    Agent.start_link(fn -> [] end, name: name)
  end

  def get(name) do
    Agent.get(name, fn list -> list end)
  end

  def push(name, user_id) do
    Agent.update(name, fn list -> [user_id | list] end)
  end

  def delete(name, user_id) do
    Agent.update(name, &List.delete(&1, user_id))
  end
end
