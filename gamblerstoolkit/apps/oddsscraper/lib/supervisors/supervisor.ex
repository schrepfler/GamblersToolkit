defmodule MlbOdds.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {MlbOdds.DynamicSupervisor, name: MlbOdds.DynamicSupervisor, strategy: :one_for_one},
      {MlbOdds.Oracle, name: MlbOdds.Oracle}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
