defmodule Pear.Session do
  def start_link do
    Agent.start_link(fn -> [] end)
  end

  def get(session) do
    Agent.get(session, fn list -> list end)
  end

  def push(session, user_id) do
    Agent.update(session, fn list -> [user_id | list] end)
  end

  def delete(session, user_id) do
    Agent.update(session, &List.delete(&1, user_id))
  end
end
