defmodule SCExecutor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application


  def heartBeat() do
    Process.sleep(1000)
    Phoenix.PubSub.broadcast(ScientificCalculatorPubsub.Service, "worker:registry:listener", [node: node()])
    heartBeat()
  end

  @impl true
  def start(_type, _args) do
    children = [
      Supervisor.child_spec(
        {
          Task,
          fn ->
            heartBeat()
          end
        },
        restart: :permanent
      ),
      {Task.Supervisor, name: SCExecutor.TaskRemoteCaller}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SCExecutor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
