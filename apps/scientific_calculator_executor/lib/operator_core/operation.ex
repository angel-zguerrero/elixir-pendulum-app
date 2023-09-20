defmodule OperatorCore.Operation do
  defstruct operation_name: nil, result: %{}, parameters: %{}, executors: [], execution_time: 0
  @type t :: %__MODULE__{operation_name: String.t(), result: Map.t(), parameters: Map.t(), executors: List.t(), execution_time: Number.t()}
end

defimpl Jason.Encoder , for: OperatorCore.Operation do
  def encode(%OperatorCore.Operation{operation_name: operation_name, result: result, parameters: parameters, executors: executors, execution_time: execution_time}, opts) do
    Jason.Encode.map(%{"operation_name" => operation_name, "result" => result, "parameters" => parameters, "executors" => executors, "execution_time" => execution_time}, opts)
  end
end
