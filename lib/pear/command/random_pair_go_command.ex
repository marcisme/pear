defmodule Pear.Command.RandomPairGoCommand do
  @behaviour Pear.Command

  def accept?(type), do: type == "message"

  def execute(event, _slack) do
    if Regex.match?(~r/go/, event.text) do
      case Pear.Session.user_ids(event) do
        user_ids when is_list(user_ids) ->
          text =
            user_ids
            |> Enum.take_random(Enum.count(user_ids))
            |> Enum.map(&("<@#{&1}>"))
            |> Enum.chunk(2, 2, [])
            |> Enum.map(fn
                 [a, b] ->
                   "[#{a}, #{b}]"
                 [a] ->
                   "[#{a}]"
               end)
            |> Enum.join(", ")
          {:rtm, :send, [event.channel, "Here are your pairs: #{text}"]}
        :nosession ->
          :halt
      end
    else
      :cont
    end
  end
end
