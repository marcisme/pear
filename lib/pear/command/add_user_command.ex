defmodule Pear.Command.AddUserCommand do
  @behaviour Pear.Command

  def accept?(event), do: event.type == "reaction_added"

  def execute(event, _slack) do
    Pear.Session.add(event.item, event.user)
    :halt
  end
end

