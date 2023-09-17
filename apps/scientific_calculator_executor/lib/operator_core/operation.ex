defmodule OperatorCore.Operation do
  defstruct operation_name: nil, result: %{}, parameters: %{}, executor: :nil, execution_time: 0
  @type t :: %__MODULE__{operation_name: String.t(), result: Map.t(), parameters: Map.t(), executor: String.t(), execution_time: Number.t()}


end
