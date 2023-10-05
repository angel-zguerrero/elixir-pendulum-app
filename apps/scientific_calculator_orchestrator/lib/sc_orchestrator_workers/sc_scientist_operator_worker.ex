defmodule SCOrchestrator.ScientistOperatorWorker do
  use Rabbit.Broker

  def start_link(opts \\ []) do
    Rabbit.Broker.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # Callbacks

  @impl Rabbit.Broker
  # Perform runtime configuration per component
  def init(:connection_pool, opts), do: {:ok, opts}
  def init(:connection, opts), do: {:ok, opts}
  def init(:topology, opts), do: {:ok, opts}
  def init(:producer_pool, opts), do: {:ok, opts}
  def init(:producer, opts), do: {:ok, opts}
  def init(:consumer_supervisor, opts), do: {:ok, opts}
  def init(:consumer, opts), do: {:ok, opts}

   @doc """
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

      executors_parameters = [ex0@8905041f38c2: %{m: 1, n: 15}, ex1@8905041f38c2: %{m: 16, n: 30}]
  """

  @impl Rabbit.Broker
  def handle_message(message) do
    rabbitmq_scientist_operations_solved = Application.fetch_env!(:scientific_calculator_orchestrator, :rabbitmq_scientist_operations_solved)
    macro_message = Jason.decode!(~s(#{message.payload}))
    operation_message = macro_message["data"]
    try do
      operation = operation_message["operation"]
      executors_parameters =
        case operation["type"] do
          "factorial" ->
            case  SCOrchestrator.Router.factorial(operation["value"]) do
              {:error, reason} -> raise(reason)
              result -> result
            end
          _ -> raise("Unexpected operation type")
        end


      tasks = executors_parameters
      |> Enum.map(fn executor_parameters ->
        {executor, args, module} = executor_parameters
          {SCExecutor.TaskRemoteCaller, executor}
          |> Task.Supervisor.async_nolink(OperatorCore, :execute, [module, args])
      end)

      remote_results = Task.await_many(tasks)

      merged_result =
        case operation["type"] do
          "factorial" -> OperatorCore.merge(OperatorCore.Factorial, remote_results)
          _ -> raise("Unexpected operation type")
        end
      operation_result = Jason.encode!(%{
        pattern: rabbitmq_scientist_operations_solved,
        _id: operation_message["_id"],
        status: "success",
        result: merged_result
      })
      IO.inspect(operation_result, label: "Got message")
      Rabbit.Broker.publish(SCOrchestrator.ScientistOperatorPublisher, "", rabbitmq_scientist_operations_solved, operation_result)
      {:ack, message}
    rescue
      e in _ ->
        handle_operation_error(inspect(e.reason), rabbitmq_scientist_operations_solved, operation_message)
        {:nack, message}
    catch
      :exit, reason ->
        handle_operation_error(inspect(reason), rabbitmq_scientist_operations_solved, operation_message)
        {:nack, message}
    end

  end

  def handle_operation_error(reason, rabbitmq_scientist_operations_solved, operation_message) do
    try do
      operation_result = Jason.encode!(%{
        pattern: rabbitmq_scientist_operations_solved,
        _id: operation_message["_id"],
        status: "failed",
        failedReason: reason
      })
      IO.inspect(operation_result, label: "Got error")
      Rabbit.Broker.publish(SCOrchestrator.ScientistOperatorPublisher, "", rabbitmq_scientist_operations_solved, operation_result)
    rescue
      e in _ ->
        IO.inspect(e)
    catch
      :exit, reason ->
        IO.inspect(reason)
    end

  end

  @impl Rabbit.Broker
  def handle_error(message) do
    # Handle message errors per consumer
    {:nack, message}
  end
end
