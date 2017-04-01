defmodule Pear.TestBot do
  use Slack
  require Logger

  # Test API

  def send_test_message(pid, text, channel) do
    send(pid, {:send_test_message, text, channel})
  end

  def react(pid, text, reaction) do
    %{channel: channel, ts: ts} = has_message(pid, text)
    send(pid, {:react, reaction, %{channel: channel, timestamp: ts}})
  end

  def has_message(pid, text) do
    Enum.find(test_messages(pid), &String.contains?(&1.text, text))
  end

  def test_messages(pid) do
    send(pid, {:test_messages, self()})
    receive do
      {:test_messages, messages} -> messages
    end
  end

  # Slack.Bot

  defmodule State do
    defstruct messages: [], token: ""
  end

  def start_link(token) do
    Slack.Bot.start_link(__MODULE__, %State{token: token}, token)
  end

  def handle_connect(slack, state) do
    Logger.debug "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, _slack, state) do
    {:ok, %State{state | messages: [message | state.messages]}}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:send_test_message, text, channel}, slack, state) do
    Logger.debug("send_test_message")
    send_message(text, channel, slack)
    {:ok, state}
  end

  def handle_info({:react, reaction, params}, _slack, state) do
    Logger.debug("react")
    Slack.Web.Reactions.add(reaction, Map.put(params, :token, state.token))
    {:ok, state}
  end

  def handle_info({:test_messages, caller}, _slack, state) do
    Logger.debug("test_messages")
    send(caller, {:test_messages, state.messages})
    {:ok, state}
  end
end

