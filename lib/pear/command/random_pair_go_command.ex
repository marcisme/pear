defmodule Pear.Command.RandomPairGoCommand do
  @behaviour Pear.Command

  def accept?(type), do: type == "message"

  def execute(message, _slack) do
    if Regex.match?(~r/go/, message.text) do
      with user_ids when is_list(user_ids) <- Pear.Session.user_ids(message) do
        text =
          user_ids
          |> Enum.map(&("<@#{&1}>"))
          |> Enum.join("\n")
        {:rtm, :send, [message.channel, "Here are your pairs: #{text}"]}
      end
    end
  end
end

