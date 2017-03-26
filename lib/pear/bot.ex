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

  def handle_event(message = %{type: "message", subtype: "message_changed"}, slack, state) do
    log_message(message)
    parse(message.message.text, slack)
    |> command(message, slack)
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    log_message(message)
    parse(message.text, slack)
    |> command(message, slack)
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  defp parse(text, slack) do
    cond do
      !String.contains?(text, slack.me.id) -> nil
      Regex.match?(~r/pair me/, text) -> :create_session
      Regex.match?(~r/do it/, text) -> :generate_pairs
      true -> nil
    end
  end

  defp command(:create_session, message, _slack) do
    response = Slack.Web.Chat.post_message(message.channel, "Bring out your pears!")
    Pear.Session.initialize(message)
    Slack.Web.Reactions.add("pear", reaction_params(response))
  end

  defp command(:generate_pairs, message, slack) do
    with user_ids when is_list(user_ids) <- Pear.Session.user_ids(message) do
      Enum.map(user_ids, &Slack.Lookups.lookup_user_name(&1, slack))
      |> Enum.join("\n")
      |> send_message(message.channel, slack)
    end
  end

  defp command(name, _message, _slack), do: name

  defp log_message(message) do
    Logger.debug "#{inspect(message)}"
  end

  defp reaction_params(%{"channel" => channel, "ts" => timestamp}) do
    %{channel: channel, timestamp: timestamp}
  end
end
