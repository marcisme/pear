defmodule Pear.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    supervise(children(), strategy: :one_for_one)
  end

  defp children do
    if Mix.env == :test do
      [supervisor(Registry, [:unique, Pear.Session])]
    else
      [
        supervisor(Registry, [:unique, Pear.Session]),
        worker(Slack.Bot, [Pear.Bot, [], Application.fetch_env!(:slack, :api_token)])
      ]
    end
  end
end
