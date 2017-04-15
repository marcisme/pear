defmodule Pear.Session do
  def initialize(event) do
    case Agent.start_link(fn -> MapSet.new end, name: via_name(event)) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Agent.update(pid, fn _ -> MapSet.new end)
        {:ok, pid}
    end
  end

  defp via_name(%{channel: channel}) do
    {:via, Registry, {__MODULE__, channel}}
  end

  def user_ids(event) do
    do_safely(event, &Agent.get(&1, fn set -> MapSet.to_list(set) end))
  end

  defp do_safely(event, action) do
    try do
      event
      |> via_name
      |> action.()
    catch
      :exit, {:noproc, _} -> :nosession
    end
  end

  def add(event, user_id) do
    do_safely(event, &Agent.update(&1, fn set -> MapSet.put(set, user_id) end))
  end

  def remove(event, user_id) do
    do_safely(event, &Agent.update(&1, fn set ->
      MapSet.delete(set, user_id)
    end))
  end
end
