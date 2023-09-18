defmodule SCOrchestrator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {SCOrchestrator.ScientistOperatorWorker, [ strategy: :one_for_rest]},
      {SCOrchestrator.ExecutorRegistryListener, [strategy: :one_for_one]}
    ]

    opts = [strategy: :one_for_one, name: SCOrchestrator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
