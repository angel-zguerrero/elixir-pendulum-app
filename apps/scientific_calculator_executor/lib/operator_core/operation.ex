defmodule OperatorCore.Operation do
  defstruct operation_name: nil, result: %{}, parameters: %{}, executors: [], execution_time: 0
  @type t :: %__MODULE__{operation_name: String.t(), result: Map.t(), parameters: Map.t(), executors: List.t(), execution_time: Number.t()}


end
