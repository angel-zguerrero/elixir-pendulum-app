defmodule SCOrchestrator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {SCOrchestrator.Router, [strategy: :one_for_rest]},
      {SCOrchestrator.ScientistOperatorWorker,
       [
         connection: [uri: "amqp://admin:admin@pendulum-app-rabbitmq:5672"],
         topology: [
           queues: [
             [name: "scientist-operations-to-solve", durable: true]
           ]
         ],
         producer: [pool_size: 10],
         consumers: [
           [queue: "scientist-operations-to-solve"]
         ]
       ]},
      {SCOrchestrator.ScientistOperatorPublisher,
       [
         connection: [uri: "amqp://admin:admin@pendulum-app-rabbitmq:5672"],
         topology: [
           queues: [
             [name: "scientist-operations-solved", durable: true]
           ]
         ],
         producer: [pool_size: 10]
       ]},
      {SCOrchestrator.ExecutorRegistryListener, [strategy: :one_for_one]}
    ]

    opts = [strategy: :one_for_one, name: SCOrchestrator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
