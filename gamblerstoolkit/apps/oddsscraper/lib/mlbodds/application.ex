defmodule MlbOdds.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Mlbodds.Worker.start_link(arg)
    ]

    MlbOdds.Supervisor.start_link(name: MlbOdds.Supervisor)
  end
end
