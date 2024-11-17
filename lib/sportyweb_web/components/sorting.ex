defmodule SportywebWeb.Sorting do
  defstruct [:sort_direction, :sorted_attribute]


  def get_valid_directions do
    [ "asc", "desc"]
  end
end
