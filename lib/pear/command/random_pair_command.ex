defmodule Pear.Command.RandomPairCommand do
  @behaviour Pear.Command
  @text "Random pairing time!\nAdd reactions to this message to participate, and tell me to \"go\" when you're ready."

  def accept?(type), do: type == "message"

  def execute(message, _slack) do
    if Regex.match?(~r/(\bpair\b|:pear:)/, message.text) do
      Pear.Session.initialize(message)
      {:web, :post_and_react, [message.channel, @text, "pear"]}
    else
      :cont
    end
  end
end
