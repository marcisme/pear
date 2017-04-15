defmodule Pear.Command.AddUserCommand do
  @behaviour Pear.Command

  def accept?(event) do
    event.type == "reaction_added" && event.item.type == "message"
  end

  def execute(event, _slack) do
    Pear.Session.add(event.item, event.user)
    :halt
  end
end

