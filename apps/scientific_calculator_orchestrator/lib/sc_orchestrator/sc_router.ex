defmodule SCOrchestrator.Router do
  use GenServer
  require Logger
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end
  def init(:ok) do
    {:ok, %{}}
  end

  def factorial(n) do
    n = if n == 0 do
      1
    else
      n
    end
    limit_factorial = Application.fetch_env!(:scientific_calculator_executor, :limit_factorial)
    IO.inspect("Router.Factorial n: #{n} limit_factorial: #{limit_factorial}")
    if(n > limit_factorial) do
      raise("Badformat, the number 'n' less than #{limit_factorial}")
    end
    GenServer.call(__MODULE__, {:factorial, n}, 20000)
  end

  def handle_call({:factorial, n}, _from, state) do
    try do
      executors_routing_table = Application.fetch_env!(:scientific_calculator_orchestrator, :executors_routing_table)
      all_executors = Map.keys(executors_routing_table)
      executors = case length(all_executors)  do
        size when size == 1 ->
          all_executors
        _ -> Enum.filter(all_executors, fn element -> "#{element}" != "#{node()}" end)
      end
      |> Enum.sort()

      max_executors = length(executors)
      if max_executors == 0 do
        raise "No executors available"
      end


      min_interval_by_executor = 10

      qt_executors =  min(ceil(n / min_interval_by_executor), max_executors)
      interval_size = ceil(n / qt_executors)
      range = 1..n
      result = range
      |> Enum.chunk_every(interval_size, interval_size)
      |> Enum.map(&{Enum.at(&1, 0), Enum.at(&1, -1)})

      final_result = executors
      |> Enum.zip(result)
      |> Enum.map(fn {executor, interval} ->
        [n, m] = Enum.reverse(Tuple.to_list(interval))
        args = %{n: Decimal.new(n), m: Decimal.new(m)}
        {executor, args, OperatorCore.Factorial}
      end)

      {:reply, final_result, state}
    rescue
      e in _ ->
      {:reply, {:error, inspect(e.reason)}, state}
    catch
      reason ->
        {:reply, {:error, inspect(reason)}, state}
    end
  end
end
