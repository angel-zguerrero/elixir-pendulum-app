defmodule OperatorCore.Operation do
  defstruct operation_name: nil, result: %{}, parameters: %{}
  @type t :: %__MODULE__{operation_name: String.t(), result: Map.t(), parameters: Map.t()}
end
