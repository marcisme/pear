defmodule Pear.Command.FilterSelfCommand do
  @behaviour Pear.Command
  @types ["reaction_added", "reaction_removed"]

  def accept?(type), do: type in @types

  def execute(event, slack) do
    if event.user == slack.me.id, do: :halt, else: :cont
  end
end
