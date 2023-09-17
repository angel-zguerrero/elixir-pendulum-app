defmodule OperatorCore.Operation do
  defstruct operation_name: nil, result: %{}, parameters: %{}, executor: :nil, execution_time: 0
  @type t :: %__MODULE__{operation_name: String.t(), result: Map.t(), parameters: Map.t(), executor: String.t(), execution_time: Number.t()}

  @spec execute(module :: OperatorCore.Operation, parameters :: Map.t) :: OperatorCore.Operation.t()
  def execute(module, parameters) do
    start_time = :os.system_time(:millisecond)
    result = module.execute(parameters)
    Map.put(result, :execution_time,  :os.system_time(:millisecond) - start_time)
  end
end
