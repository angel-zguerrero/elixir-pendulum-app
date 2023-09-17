defmodule OperatorCore.Factorial do
  @behaviour OperatorCore

  @spec execute(parameters :: Map.t) :: OperatorCore.Operation.t()
  def execute(parameters) do

    %OperatorCore.Operation{operation_name: "factorial", result: %{}, parameters: parameters}
  end
end
