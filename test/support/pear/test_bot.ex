defmodule Pear.TestBot do
  use Slack
  require Logger

  # Test API

  def send_test_message(pid, text, channel) do
    send(pid, {:send_test_message, text, channel})
  end

  def react(pid, text, reaction) do
    %{channel: channel, ts: ts} = has_message_starting_with(pid, text)
    send(pid, {:react, reaction, %{channel: channel, timestamp: ts}})
  end

  def has_message(pid, text) do
    Enum.find(test_messages(pid), &(&1.text == text))
  end

  def has_message_starting_with(pid, text) do
    Enum.find(test_messages(pid), &String.starts_with?(&1.text, text))
  end

  def test_messages(pid) do
    send(pid, {:test_messages, self()})
    receive do
      {:test_messages, messages} -> messages
    end
  end

  # Slack.Bot

  defmodule State do
    defstruct messages: [], latests: %{}, token: ""
  end

  def start_link(token) do
    Slack.Bot.start_link(__MODULE__, %State{token: token}, token)
  end

  def handle_connect(slack, state) do
    latests =
      slack
      |> Map.take([:groups, :channels])
      |> Map.values()
      |> Enum.flat_map(&Map.values/1)
      |> Enum.filter(&Map.has_key?(&1, :latest))
      |> Enum.reduce(%{}, &Map.put(&2, &1.id, &1.latest.ts))
    Logger.debug "Connected as #{slack.me.name}, latests: #{inspect(latests)}"
    {:ok, %{state | latests: latests}}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    messages =
      if message.ts > state.latests[message.channel] do
        Logger.debug "#{slack.me.name}: #{inspect(message)}"
        [message | state.messages]
      else
        state.messages
      end
    {:ok, %State{state | messages: messages}}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:send_test_message, text, channel}, slack, state) do
    text
    |> map_user_name_to_basic_messaging_format(slack)
    |> send_message(channel, slack)
    {:ok, state}
  end

  def handle_info({:react, reaction, params}, _slack, state) do
    Slack.Web.Reactions.add(reaction, Map.put(params, :token, state.token))
    {:ok, state}
  end

  def handle_info({:test_messages, caller}, slack, state) do
    messages = map_user_ids_to_names(state.messages, slack)
    send(caller, {:test_messages, messages})
    {:ok, state}
  end

  defp map_user_ids_to_names(messages, slack) do
    Enum.map(messages, fn message ->
      text =
        Regex.replace(~r/(<@[^>]+>)/, message.text, fn _, user_id ->
          Regex.replace(~r/[@<>]/, user_id, "")
          |> Slack.Lookups.lookup_user_name(slack)
        end)
      %{message | text: text}
    end)
  end

  defp map_user_name_to_basic_messaging_format(text, slack) do
    Regex.replace(~r/(@\w+)/, text, fn _, user_name ->
      "<@#{Slack.Lookups.lookup_user_id(user_name, slack)}>"
    end)
  end
end

