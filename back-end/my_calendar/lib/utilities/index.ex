defmodule Utilities do
  @spec sanitize_map(map()) :: map()
  def sanitize_map(map) do
    Map.drop(map, [:__meta__, :__struct__])
  end
end
