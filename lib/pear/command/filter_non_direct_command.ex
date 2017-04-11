defmodule Pear.Command.FilterNonDirectCommand do
  @behaviour Pear.Command

  def accept?(type), do: type == "message"

  def execute(message, slack) do
    if Regex.match?(~r/<@#{slack.me.id}>/, message.text), do: :cont, else: :halt
  end
end
