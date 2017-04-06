defmodule Pear.Command.AddUserCommand do
  @behaviour Pear.Command

  def accept?(type), do: type == "reaction_added"

  def execute(message, _slack) do
    Pear.Session.add(message.item, message.user)
    :halt
  end
end

