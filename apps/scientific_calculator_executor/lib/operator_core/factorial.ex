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
    %OperatorCore.Operation{operation_name: "factorial", result:  %{value: operation0.result.value * operation1.result.value}, parameters: %{n: max(operation0.parameters.n, operation1.parameters.n), m: min(operation0.parameters.m, operation1.parameters.m)}, executors: operation0.executors ++ operation1.executors , execution_time: (operation0.execution_time + operation1.execution_time)/2}
  end

  def factorial(0, _m) do
    1
  end
  def factorial(n, _m) when n < 0 do
    raise("Badformat, the number 'n' must be positive")
  end
  def factorial(n, _m) when n > 13000 do
    raise("Badformat, the number 'n' less than 13000")
  end
  def factorial(_n, m) when m == 0 do
    raise("Badformat, the number 'm' must be greater than 0")
  end
  def factorial(n, m) when m >= n  do
    raise("Badformat, 'm' must be less than 'n'")
  end

  def factorial(n, m) do
    if(n - 1 > m) do
      n * factorial(n - 1, m)
    else
      n * (n - 1)
    end
  end

end
