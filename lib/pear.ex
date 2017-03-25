defmodule Pear do
  use Application

  def start(_type, args) do
    Pear.Supervisor.start_link(args)
  end
end
