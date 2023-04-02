defmodule ArraySort do
  @moduledoc """
  A sorting utility that converts lists to arrays for a potential speed improvement.
  """

  def merge_sort([]), do: []
  def merge_sort([_] = list), do: list

  def merge_sort(list) when is_list(list) do
    list
    |> :array.from_list()
    |> merge_sort_arr()
    |> :array.to_list()
  end

  def merge_sort_arr(array) do
    size = :array.size(array)

    if size <= 1 do
      array
    else
      {left, right} = ArraySlice.halve(array, size)
      a = merge_sort_arr_slice(left)
      b = merge_sort_arr_slice(right)
      ArraySlice.merge(a, b, :array.new())
    end
  end

  @spec merge_sort_arr_slice(ArraySlice.t()) :: :array.array() | ArraySlice.t()
  def merge_sort_arr_slice(%ArraySlice{size: size} = slice) do
    if size <= 1 do
      slice
    else
      {left, right} = ArraySlice.halve(slice)
      a = merge_sort_arr_slice(left)
      b = merge_sort_arr_slice(right)
      ArraySlice.merge(a, b, :array.new())
    end
  end
end
