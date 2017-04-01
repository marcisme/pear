defmodule Pear.Bot do
  use Slack
  require Logger

  @commands [
    Pear.Command.RandomPairCommand,
    Pear.Command.RandomPairGoCommand
  ]

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
    # yeah...
    Map.put(message, :text, message.message.text)
    |> dispatch(slack)
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    log_message(message)
    dispatch(message, slack)
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  defp dispatch(message, slack) do
    Enum.find(@commands, fn command ->
      case command.execute(message) do
        {service, action, args} ->
          command(service, action, args, message, slack)
        :unknown_session -> nil
        nil -> nil
      end
    end)
  end

  defp log_message(message) do
    Logger.debug "#{inspect(message)}"
  end

  defp command(:web, :post_and_react, [text, reaction], message, _slack) do
    params =
      Slack.Web.Chat.post_message(message.channel, text)
      |> reaction_params()
    Slack.Web.Reactions.add(reaction, params)
  end

  defp command(:rtm, :send, text, message, slack) do
    replace_user_ids_with_names(text, slack)
    |> send_message(message.channel, slack)
  end

  defp replace_user_ids_with_names(text, slack) do
    Regex.replace(~r/({U[^}]+})/, text, fn _, user_id ->
      Regex.replace(~r/[{}]/, user_id, "")
      |> Slack.Lookups.lookup_user_name(slack)
    end)
  end

  defp reaction_params(%{"channel" => channel, "ts" => timestamp}) do
    %{channel: channel, timestamp: timestamp}
  end
end

defmodule Pear.Command.RandomPairCommand do
  def execute(message) do
    if Regex.match?(~r/pair me/, message.text) do
      Pear.Session.initialize(message)
      {:web, :post_and_react, ["Bring out your pears!", "pear"]}
    end
  end
end

defmodule Pear.Command.RandomPairGoCommand do
  def execute(message) do
    if Regex.match?(~r/go/, message.text) do
      with user_ids when is_list(user_ids) <- Pear.Session.user_ids(message) do
        text =
          user_ids
          |> Enum.map(&("{#{&1}}"))
          |> Enum.join("\n")
        {:rtm, :send, "Here are your pairs: #{text}"}
      end
    end
  end
end

