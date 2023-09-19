defmodule SCOrchestrator.Router do
  use GenServer
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end
  def init(:ok) do
    {:ok, %{}}
  end

  def factorial(n) do
    GenServer.call(__MODULE__, {:factorial, n})
  end

  def handle_call({:factorial, n}, _from, state) do
    executors_routing_table = Application.fetch_env!(:scientific_calculator_orchestrator, :executors_routing_table)
    all_executors = Map.keys(executors_routing_table)
    executors = case length(all_executors)  do
      size when size == 1 ->
        all_executors
      _ -> Enum.filter(all_executors, fn element -> "#{element}" != "#{node()}" end)
    end
    |> Enum.sort()
    max_executors = length(executors)
    min_interval_by_executor = 10
    qt_executors =  min(ceil(n / min_interval_by_executor), max_executors)
    interval_size = ceil(n / qt_executors)
    range = 1..n
    result = Enum.chunk_every(range, interval_size, interval_size)
    {:reply, Enum.zip(executors, result), state}
  end
end
