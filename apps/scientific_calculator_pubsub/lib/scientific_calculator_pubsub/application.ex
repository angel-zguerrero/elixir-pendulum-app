defmodule ScientificCalculatorPubsub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    if node() == :nonode@nohost do
      exit("sname is required for start scientific_calculator_pubsub applicacion")
    end
    redis_host = Application.fetch_env!(:scientific_calculator_pubsub, :redis_host)
    redis_port = Application.fetch_env!(:scientific_calculator_pubsub, :redis_port)

    children = [
      {Phoenix.PubSub,
       name: ScientificCalculatorPubsub.Service,
       adapter: Phoenix.PubSub.Redis, host: redis_host, port: redis_port, node_name: "#{node()}"}
    ]

    opts = [strategy: :one_for_one, name: ScientificCalculatorPubsub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
