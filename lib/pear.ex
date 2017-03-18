defmodule Pear do
  use Application

  def start(_type, _args) do
    Pear.Supervisor.start_link
  end
end
