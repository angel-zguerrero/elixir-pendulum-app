defmodule SCOrchestrator.ScientistOperatorWorker do
  use Broadway
  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayRabbitMQ.Producer,
          queue: "scientist-operations-to-solve",
          declare: [
            durable: true
          ],
          connection: [
            port: "5672",
            username: "admin",
            password: "admin",
            host: "pendulum-app-rabbitmq"
          ]
        },
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 10
        ]
      ]
    )
  end

  def handle_message(_, message, _) do
    IO.puts("List active process local and remotes!")
    IO.inspect(message.data, label: "Got message")
    message
  end
end
