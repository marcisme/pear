defmodule Pear.Command.FilterSelfCommand do
  @behaviour Pear.Command
  @types ["reaction_added", "reaction_removed"]

  def accept?(type), do: type in @types

  def execute(message, slack) do
    if message.user == slack.me.id, do: :halt, else: :cont
  end
end
