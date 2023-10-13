defmodule OperatorCore.Factorial do
  @behaviour OperatorCore

  @spec execute(parameters :: Map.t) :: OperatorCore.Operation.t()
  def execute(parameters) do
    pid = self()
    |> :erlang.pid_to_list()
    |> to_string()
    %OperatorCore.Operation{operation_name: "factorial", result:  %{value: factorial(parameters.n, parameters.m)}, parameters: parameters, executors: ["#{node()} - #{pid}"], execution_time: 0}
  end

  @callback merge_compare(operation0 :: OperatorCore.Operation.t(), operation1 :: OperatorCore.Operation.t()) :: OperatorCore.Operation.t()
  def merge_compare(operation0, operation1) do
    %OperatorCore.Operation{operation_name: "factorial", result:  %{value: Decimal.mult(operation0.result.value, operation1.result.value)}, parameters: %{n: Decimal.max(operation0.parameters.n, operation1.parameters.n), m: Decimal.min(operation0.parameters.m, operation1.parameters.m)}, executors: operation0.executors ++ operation1.executors , execution_time: (operation0.execution_time + operation1.execution_time)/2}
  end

  def factorial(n, m) do
    limit_factorial = Application.fetch_env!(:scientific_calculator_executor, :limit_factorial)
    cond do
      Decimal.compare(n, Decimal.new(0)) == :eq -> 1
      Decimal.compare(n, Decimal.new(0)) == :lt ->  raise("Badformat, the number 'n' must be positive")
      Decimal.compare(n, Decimal.new( limit_factorial)) == :gt -> raise("Badformat, the number 'n' less than #{limit_factorial}")
      Decimal.compare(m, Decimal.new(0)) == :eq -> raise("Badformat, the number 'm' must be greater than 0")
      Decimal.compare(m, n) == :gt -> raise("Badformat, 'm' must be less than 'n'")
      Decimal.compare(n, Decimal.new(0)) == :eq -> Decimal.new(1)
      Decimal.compare(n, Decimal.new(1)) == :eq -> Decimal.new(1)

      true ->
        n_minus_1 = Decimal.sub(n, Decimal.new(1))
        n_compare_m = Decimal.compare(n_minus_1, m)
        if(n_compare_m == :gt) do
          Decimal.mult(n, factorial(n_minus_1, m))
        else
          Decimal.mult(n, n_minus_1)
        end
    end
  end
end
