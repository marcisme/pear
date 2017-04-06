defmodule Pear.Bot do
  use Slack
  require Logger

  @commands [
    Pear.Command.FilterSelfCommand,
    Pear.Command.RandomPairCommand,
    Pear.Command.RandomPairGoCommand,
    Pear.Command.AddUserCommand,
    Pear.Command.RemoveUserCommand,
  ]

  def handle_connect(slack, state) do
    Logger.debug "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "reaction_added"}, slack, state) do
    dispatch(message, slack, state)
  end

  def handle_event(message = %{type: "reaction_removed"}, slack, state) do
    dispatch(message, slack, state)
  end

  def handle_event(message = %{type: "message", subtype: "message_changed"}, slack, state) do
    # yeah...
    message
    |> Map.put(:text, message.message.text)
    |> dispatch(slack, state)
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    dispatch(message, slack, state)
  end
  def handle_event(_, _, state), do: {:ok, state}

  defp dispatch(message, slack, state) do
    Logger.debug "#{slack.me.name}: #{inspect(message)}"
    Enum.find(@commands, fn command ->
      if command.accept?(message.type) do
        case command.execute(message, slack) do
          {service, action, args} ->
            command(service, action, args, slack)
            true
          :halt ->
            true
          :cont ->
            false
        end
      end
    end)
    {:ok, state}
  end

  defp command(:web, :post_and_react, [channel, text, reaction], _slack) do
    %{"channel" => channel, "ts" => ts} = Slack.Web.Chat.post_message(channel, text)
    Slack.Web.Reactions.add(reaction, %{channel: channel, timestamp: ts})
  end

  defp command(:rtm, :send, [channel, text], slack) do
    send_message(text, channel, slack)
  end
end

