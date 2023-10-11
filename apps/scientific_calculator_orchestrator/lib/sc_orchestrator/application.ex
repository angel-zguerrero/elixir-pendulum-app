defmodule SCOrchestrator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    rabbitmq_url = Application.fetch_env!(:scientific_calculator_orchestrator, :rabbitmq_url)
    rabbitmq_scientist_operations_to_solve_queue = Application.fetch_env!(:scientific_calculator_orchestrator, :rabbitmq_scientist_operations_to_solve_queue)
    rabbitmq_scientist_operations_solved = Application.fetch_env!(:scientific_calculator_orchestrator, :rabbitmq_scientist_operations_solved)
    children = [
      {SCOrchestrator.Router, [strategy: :one_for_one]},
      {SCOrchestrator.ScientistOperatorPublisher,
       [
         connection: [uri: rabbitmq_url],
         topology: [
           queues: [
             [name: rabbitmq_scientist_operations_solved, durable: true, arguments: ["x-message-deduplication": true]]
           ]
         ],
         producer: [pool_size: 10]
      ]},
      {SCOrchestrator.ScientistOperatorWorker,
       [
         connection: [uri: rabbitmq_url],
         topology: [
           queues: [
             [name: rabbitmq_scientist_operations_to_solve_queue, durable: true, arguments: ["x-message-deduplication": true]]
           ]
         ],
         producer: [pool_size: 10],
         consumers: [
           [queue: rabbitmq_scientist_operations_to_solve_queue, timeout: 600_000, prefetch_count: 3]
         ]
       ]},
      {SCOrchestrator.ExecutorRegistryListener, [strategy: :one_for_one]}
    ]

    opts = [strategy: :one_for_one, name: SCOrchestrator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
