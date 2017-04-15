defmodule Pear.Command.AddUserCommand do
  @behaviour Pear.Command

  def accept?(type), do: type == "reaction_added"

  def execute(event, _slack) do
    Pear.Session.add(event.item, event.user)
    :halt
  end
end

