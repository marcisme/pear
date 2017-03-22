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

  def user_ids(message) do
    with [{pid, _}] <- Registry.lookup(__MODULE__, key(message)) do
      Agent.get(pid, fn list -> list end)
    end
  end

  def add(message, user_id) do
    with [{pid, _}] <- Registry.lookup(__MODULE__, key(message)) do
      Agent.update(pid, fn list -> [user_id | list] end)
    end
  end

  def remove(message, user_id) do
    with [{pid, _}] <- Registry.lookup(__MODULE__, key(message)) do
      Agent.update(pid, &List.delete(&1, user_id))
    end
  end

  defp via_name(%{channel: channel}) do
    {:via, Registry, {__MODULE__, channel}}
  end

  defp key(%{channel: channel}), do: channel
end
