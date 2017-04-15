defmodule Pear.Command.HelpCommand do
  @behaviour Pear.Command
  # @text "Random pairing time!\nAdd reactions to this message to participate, and tell me to \"go\" when you're ready."

  def accept?(event), do: event.type == "message"

  def execute(event, _slack) do
    if Regex.match?(~r/\bhelp\b/, event.text) do
      {:help, event.channel}
    else
      {:rtm, :send, [event.channel, "I'm sorry, I don't know how to do that. Ask me for \"help\" to see what I respond to."]}
    end
  end
end
