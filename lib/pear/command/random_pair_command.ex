defmodule Pear.Command.RandomPairCommand do
  @behaviour Pear.Command

  def accept?(type), do: type == "message"

  def execute(message, _slack) do
    if Regex.match?(~r/\bpair\b/, message.text) do
      Pear.Session.initialize(message)
      {:web, :post_and_react, [message.channel, "Bring out your pears!", "pear"]}
    else
      :cont
    end
  end
end
