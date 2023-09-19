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

  """
  Message example
  {
    "pattern": "scientist-operations-to-solve",
    "data": {
      "operation": {
        "type": "factorial",
        "value": 30
      },
      "status": "pending",
      "ttl": "2023-09-20T12:23:21.676Z",
      "_id": "650997ac5a6800bff0e6ef80",
      "createdAt": "2023-09-19T12:44:28.442Z",
      "updatedAt": "2023-09-19T12:44:28.442Z",
      "__v": 0
    },
    "id": "dd7364ba72958ebcdedd5"
  }

  executors_parameters = [ex0@8905041f38c2: {1, 15}, ex1@8905041f38c2: {16, 30}]
  """

  def handle_message(_, message, _) do
    macro_message = Jason.decode!(~s(#{message.data}))
    operation_message = macro_message["data"]
    operation = operation_message["operation"]
    executors_parameters = case operation["type"] do
      "factorial" -> SCOrchestrator.Router.factorial(operation["value"])
      _ -> raise("Unexpected operation type")
    end

    executors_parameters
    |>Enum.each(
      fn executor_parameters ->
        {executor, interval} = executor_parameters
        [n, m] = Enum.reverse(Tuple.to_list(interval))
        result = {SCExecutor.TaskRemoteCaller, executor}
        |>Task.Supervisor.async(OperatorCore, :execute, [OperatorCore.Factorial, %{n: n, m: m}])
        |>Task.await()
        IO.inspect("result:")
        IO.inspect(result)
    end)



    IO.inspect(executors_parameters, label: "Got message")
    message
  end
end
