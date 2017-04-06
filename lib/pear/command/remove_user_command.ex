defmodule Pear.Command.RemoveUserCommand do
  @behaviour Pear.Command

  def accept?(type), do: type == "reaction_removed"

  def execute(message, _slack) do
    Pear.Session.remove(message.item, message.user)
    :halt
  end
end

