defmodule OperatorCore do
  @callback execute(parameters :: Map.t() ) :: OperatorCore.Operation.t()

  @spec execute(module :: OperatorCore.Operation, parameters :: Map.t) :: OperatorCore.Operation.t()
  def execute(module, parameters) do
    start_time = :os.system_time(:millisecond)
    result = module.execute(parameters)
    Map.put(result, :execution_time,  :os.system_time(:millisecond) - start_time)
  end
end
