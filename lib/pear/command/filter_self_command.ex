defmodule Pear.Command.FilterSelfCommand do
  @behaviour Pear.Command
  @event_types ["reaction_added", "reaction_removed"]

  def accept?(event), do: event.type in @event_types

  def execute(event, slack) do
    if event.user == slack.me.id, do: :halt, else: :cont
  end
end
