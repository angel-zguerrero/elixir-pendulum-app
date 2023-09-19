defmodule SCOrchestrator.ExecutorRegistryListener do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_init_arg) do
    Phoenix.PubSub.subscribe(ScientificCalculatorPubsub.Service, "worker:registry:listener")
    {:ok, %{}}
  end

  def handle_info(remote_node_info, state) do
    require Logger
    executors_routing_table = Application.fetch_env!(:scientific_calculator_orchestrator, :executors_routing_table)
    #Logger.debug("executors_routing_table : #{inspect(executors_routing_table)}")
    time_life = 60
    current_time = DateTime.utc_now()
    ttl = DateTime.add(current_time, time_life, :second)
    executors_routing_table = Map.put(executors_routing_table, remote_node_info[:node], ttl)
    keys_to_remove =
      Enum.filter(Map.keys(executors_routing_table), fn remote_node ->
        node_ttl = executors_routing_table[remote_node]
        time_diff = DateTime.diff(node_ttl, current_time, :second)
        time_diff <= 0
      end)
    Application.put_env(:scientific_calculator_orchestrator, :executors_routing_table, Map.drop(executors_routing_table, keys_to_remove))
    {:noreply, state}
  end
end
