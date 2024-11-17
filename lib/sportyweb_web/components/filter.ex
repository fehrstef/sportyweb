defmodule SportywebWeb.Filter do
  defstruct [:operator, :attribute, :value]


  def get_valid_operators do
    [ "==", "!="]
  end
end
