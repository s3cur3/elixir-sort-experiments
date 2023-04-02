defmodule ArraySort do
  @moduledoc """
  A sorting utility that converts lists to arrays for a potential speed improvement.
  """

  def merge_sort([]), do: []
  def merge_sort([_] = list), do: list

  def merge_sort(list) when is_list(list) do
    list
    |> :array.from_list()
    |> ArraySlice.new()
    |> merge_sort_arr_slice()
    |> ArraySlice.to_list()
  end

  @spec merge_sort_arr_slice(ArraySlice.t()) :: :array.array() | ArraySlice.t()
  def merge_sort_arr_slice(%ArraySlice{size: 1} = slice), do: slice

  def merge_sort_arr_slice(%ArraySlice{} = slice) do
    {left, right} = ArraySlice.halve(slice)
    a = merge_sort_arr_slice(left)
    b = merge_sort_arr_slice(right)
    ArraySlice.merge(a, b)
  end
end
