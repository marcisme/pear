defmodule Pear.Bot do
  use Slack
  require Logger

  @types [
    "message",
    "reaction_added",
    "reaction_removed",
  ]

  @ignored_event_subtypes [
    "message_deleted",
    "message_replied",
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

  def handle_event(%{type: "message", subtype: subtype}, _slack, state)
  when subtype in @ignored_event_subtypes do
    {:ok, state}
  end

  def handle_event(event = %{type: "message", subtype: "message_changed"}, slack, state) do
    # yeah...
    event
    |> Map.put(:text, event.message.text)
    |> dispatch(slack, state)
    {:ok, state}
  end

  def handle_event(event = %{type: type}, slack, state) when type in @types do
    dispatch(event, slack, state)
  end
  def handle_event(_event, _slack, state), do: {:ok, state}

  defp dispatch(event, slack, state) do
    Logger.debug "#{slack.me.name}: #{inspect(event)}"
    found = Enum.find(@commands, fn command ->
      if command.accept?(event.type) do
        case command.execute(event, slack) do
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
    if !found, do: help(event.channel, slack)
    {:ok, state}
  end

  defp slack(:web, :post_and_react, [channel, text, reaction], _slack) do
    %{"channel" => channel, "ts" => ts} = Slack.Web.Chat.post_message(channel, text, with_token())
    Slack.Web.Reactions.add(reaction, with_token(%{channel: channel, timestamp: ts}))
  end

  defp slack(:rtm, :send, [channel, text], slack) do
    send_message(text, channel, slack)
  end

  defp with_token, do: with_token(%{})
  defp with_token(map) do
    Map.merge(%{token: Config.get(:slack, :api_token)}, map)
  end

  defp help(channel, slack) do
    send_message("""
    I'm sorry, I don't know how to do that.
    I can help you organize a random pairing session if you tell me to \"pair\".
    """, channel, slack)
  end
end
