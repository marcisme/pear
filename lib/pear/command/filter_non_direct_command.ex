defmodule Pear.Command.FilterNonDirectCommand do
  @behaviour Pear.Command

  def accept?(event), do: event.type == "message"

  def execute(event, slack) do
    if Regex.match?(~r/<@#{slack.me.id}>/, event.text), do: :cont, else: :halt
  end
end
