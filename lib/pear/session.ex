defmodule Pear.Session do
  def initialize(message) do
    case Agent.start_link(fn -> [] end, name: via_name(message)) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Agent.update(pid, fn _ -> [] end)
        {:ok, pid}
    end
  end

  defp via_name(%{channel: channel}) do
    {:via, Registry, {__MODULE__, channel}}
  end

  def user_ids(message) do
    do_safely(message, &Agent.get(&1, fn list -> list end))
  end

  defp do_safely(message, action) do
    try do
      via_name(message)
      |> action.()
    catch
      :exit, {:noproc, _} -> :unknown_session
    end
  end

  def add(message, user_id) do
    do_safely(message, &Agent.update(&1, fn list -> [user_id | list] end))
  end

  def remove(message, user_id) do
    do_safely(message, &Agent.update(&1, fn list ->
      List.delete(list, user_id)
    end))
  end
end
