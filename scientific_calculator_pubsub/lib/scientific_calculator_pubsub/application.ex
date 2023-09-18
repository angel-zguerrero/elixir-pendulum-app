defmodule ScientificCalculatorPubsub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub,
       name: ScientificCalculatorPubsub.Service,
       adapter: Phoenix.PubSub.Redis, host: "pendulum-app-redis", port: 6379, node_name: System.get_env("NODE")}
    ]

    opts = [strategy: :one_for_one, name: ScientificCalculatorPubsub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
