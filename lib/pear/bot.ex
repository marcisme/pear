defmodule Pear.Bot do
  use Slack
  require Logger

  def handle_connect(slack, state) do
    Logger.debug "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "reaction_added"}, slack, state) do
    log_message(message)
    if message.user != slack.me.id do
      Pear.Session.add(message.item, message.user)
    end
    {:ok, state}
  end
  def handle_event(message = %{type: "reaction_removed"}, slack, state) do
    log_message(message)
    if message.user != slack.me.id do
      Pear.Session.remove(message.item, message.user)
    end
    {:ok, state}
  end
  def handle_event(message = %{type: "message"}, slack, state) do
    log_message(message)
    cond do
      Regex.match?(~r/pair me/, message.text) ->
        response = Slack.Web.Chat.post_message(message.channel, "Bring out your pears!", token_params())
        Pear.Session.initialize(message)
        Slack.Web.Reactions.add("pear", reaction_params(response))
      Regex.match?(~r/do it/, message.text) ->
        participants =
          Pear.Session.user_ids(message)
          |> Enum.map(&Slack.Lookups.lookup_user_name(&1, slack))
          |> Enum.join("\n")
        send_message(participants, message.channel, slack)
      true -> nil
    end
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  defp log_message(message) do
    Logger.debug "#{inspect(message)}"
  end

  defp token_params do
    %{
      token: Application.fetch_env!(:pear, :token)
    }
  end

  defp reaction_params(%{"channel" => channel, "ts" => timestamp}) do
    Map.merge(%{channel: channel, timestamp: timestamp}, token_params())
  end
end
