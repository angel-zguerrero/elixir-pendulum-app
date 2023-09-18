defmodule ScientificCalculatorPubsub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_host_env = System.get_env("REDIS_HOST")
    redis_port_env = System.get_env("REDIS_PORT")

    redis_host = case redis_host_env do
      :nil -> "pendulum-app-redis"
      _ -> redis_host_env
    end

    redis_port = case redis_port_env do
      :nil -> 6379
      _ -> String.to_integer(redis_port_env)
    end
    children = [
      {Phoenix.PubSub,
       name: ScientificCalculatorPubsub.Service,
       adapter: Phoenix.PubSub.Redis, host: redis_host, port: redis_port, node_name: "#{node()}"}
    ]

    opts = [strategy: :one_for_one, name: ScientificCalculatorPubsub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
