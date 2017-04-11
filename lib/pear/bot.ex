defmodule Pear.Bot do
  use Slack
  require Logger

  @types [
    "message",
    "reaction_added",
    "reaction_removed",
  ]

  @commands [
    Pear.Command.FilterSelfCommand,
    Pear.Command.FilterNonDirectCommand,
    Pear.Command.RandomPairCommand,
    Pear.Command.RandomPairGoCommand,
    Pear.Command.AddUserCommand,
    Pear.Command.RemoveUserCommand,
  ]

  def handle_connect(slack, state) do
    Logger.debug "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message", subtype: "message_changed"}, slack, state) do
    # yeah...
    message
    |> Map.put(:text, message.message.text)
    |> dispatch(slack, state)
    {:ok, state}
  end

  def handle_event(message = %{type: type}, slack, state) when type in @types do
    dispatch(message, slack, state)
  end
  def handle_event(_, _, state), do: {:ok, state}

  defp dispatch(message, slack, state) do
    Logger.debug "#{slack.me.name}: #{inspect(message)}"
    found = Enum.find(@commands, fn command ->
      if command.accept?(message.type) do
        case command.execute(message, slack) do
          {service, action, args} ->
            slack(service, action, args, slack)
            true
          :halt ->
            true
          :cont ->
            false
        end
      end
    end)
    if !found, do: help(message.channel, slack)
    {:ok, state}
  end

  defp slack(:web, :post_and_react, [channel, text, reaction], _slack) do
    %{"channel" => channel, "ts" => ts} = Slack.Web.Chat.post_message(channel, text)
    Slack.Web.Reactions.add(reaction, %{channel: channel, timestamp: ts})
  end

  defp slack(:rtm, :send, [channel, text], slack) do
    send_message(text, channel, slack)
  end

  defp help(channel, slack) do
    send_message("""
    I'm sorry, I don't know how to do that.
    I can help you organize a random pairing session if you tell me to \"pair\".
    """, channel, slack)
  end
end
