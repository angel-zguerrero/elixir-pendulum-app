defmodule OperatorCore do
  @callback execute(parameters :: Map.t() ) :: OperatorCore.Operation.t()
  @callback merge_compare(operation0 :: OperatorCore.Operation.t(), operation1 :: OperatorCore.Operation.t()) :: OperatorCore.Operation.t()

  @spec execute(module :: OperatorCore.Operation, parameters :: Map.t) :: OperatorCore.Operation.t()
  def execute(module, parameters) do
    start_time = :os.system_time(:millisecond)
    result = module.execute(parameters)
    Map.put(result, :execution_time,  :os.system_time(:millisecond) - start_time)
  end

  def merge(module, operations) do
    merged_result = if length(operations) == 1 || length(operations) == 0 do
        hd(operations)
      else
        operations
        |> Enum.reduce(fn element, acc ->
          module.merge_compare(element, acc)
        end)
      end

      result = merged_result.result
      big_number = Decimal.to_string(result.value, :scientific)
      result_updated = Map.put(result, :value, "#{big_number}")
      Map.put(merged_result, :result, result_updated)
  end


end
