defmodule Pear.Supervisor do
  use Supervisor

  def start_link(options) do
    Supervisor.start_link(__MODULE__, options)
  end

  def init(options) do
    supervise(children(options), strategy: :one_for_one)
  end

  defp children(options) do
    if options[:start_bot] do
      [supervisor(Registry, [:unique, Pear.Session]),
       worker(Slack.Bot, [Pear.Bot, [], Application.fetch_env!(:slack, :api_token)])]
    else
      [supervisor(Registry, [:unique, Pear.Session])]
    end
  end
end
