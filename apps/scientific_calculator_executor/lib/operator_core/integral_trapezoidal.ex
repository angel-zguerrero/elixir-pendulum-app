
defmodule OperatorCore.IntegralTrapezoidal do
  @behaviour OperatorCore

  @spec execute(parameters :: Map.t) :: OperatorCore.Operation.t()
  def execute(parameters) do
    pid = self()
    |> :erlang.pid_to_list()
    |> to_string()
    %OperatorCore.Operation{operation_name: "integral_trapezoidal", result:  %{value: integral_trapezoidal(parameters.function, parameters.a, parameters.b, parameters.epsilon)}, parameters: parameters, executors: ["#{node()} - #{pid}"], execution_time: 0}
  end

  @callback merge_compare(operation0 :: OperatorCore.Operation.t(), operation1 :: OperatorCore.Operation.t()) :: OperatorCore.Operation.t()
  def merge_compare(operation0, operation1) do
    %OperatorCore.Operation{operation_name: "integral_trapezoidal", result:  %{value: Decimal.add(operation0.result.value, operation1.result.value)}, parameters: %{a: Decimal.min(operation0.parameters.a, operation1.parameters.a), b: Decimal.max(operation0.parameters.b, operation1.parameters.b)}, executors: operation0.executors ++ operation1.executors , execution_time: (operation0.execution_time + operation1.execution_time)/2}
  end

  def integral_trapezoidal(function, ad, bd, epsilond) do
    a = Decimal.to_float(ad)
    b = Decimal.to_float(bd)
    epsilon = Decimal.to_float(epsilond)

    n = round(Float.round((b - a) / epsilon))  # Calculate the number of iterations as an integer
    delta_x = (b - a) / n
    result = Enum.reduce(0..(n - 1), 0.0, fn i, acc ->
      x1 = a + i * delta_x
      x2 = a + (i + 1) * delta_x
      (Abacus.eval!(function, %{x: x1}) + Abacus.eval!(function, %{x: x2})) / 2.0 * delta_x + acc
    end)
    Decimal.new("#{result}")
  end

"""
def integral_trapezoidal(function, a, b, epsilon) do
  b_minus_a = Decimal.sub(Decimal.new(b), Decimal.new(a))
  n = Decimal.to_integer(Decimal.round(Decimal.div(b_minus_a, epsilon)))

  delta_x = Decimal.div(b_minus_a, Decimal.new(n))
  result = Enum.reduce(0..(n - 1), 0.0, fn i, acc ->
    x1 = Decimal.add(Decimal.new(a),  Decimal.mult(Decimal.new(i), delta_x))
    x2 = Decimal.add(Decimal.new(a), Decimal.mult(Decimal.add(Decimal.new(i), Decimal.new(1)), delta_x))
    (Abacus.eval!(function, %{x: Decimal.to_float(x1) }) + Abacus.eval!(function, %{x: Decimal.to_float(x2)})) / 2.0 * Decimal.to_float(delta_x) + acc
  end)
  Decimal.new(result)
end
"""
end
