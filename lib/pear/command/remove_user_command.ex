defmodule Pear.Command.RemoveUserCommand do
  @behaviour Pear.Command

  def accept?(event), do: event.type == "reaction_removed"

  def execute(event, _slack) do
    Pear.Session.remove(event.item, event.user)
    :halt
  end
end

