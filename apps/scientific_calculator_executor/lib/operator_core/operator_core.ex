defmodule OperatorCore do
  @callback execute(parameters :: Map.t() ) :: OperatorCore.Operation.t()
end
