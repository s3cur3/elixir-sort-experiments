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
      {left, right} = halve_arr(array, size)
      a = merge_sort_arr(left)
      b = merge_sort_arr(right)
      merge(a, b, :array.new(size))
    end
  end

  def merge(left, right, acc) do
    # IO.inspect(:array.to_list(left), label: "merging left", charlists: :as_lists)
    # IO.inspect(:array.to_list(right), label: "merging right", charlists: :as_lists)
    right_size = :array.size(right)

    {insertion_idx, idx_right, merged} =
      :array.foldl(
        fn
          _idx_left, val_left, {insertion_idx, idx_right, acc} when idx_right >= right_size ->
            # Take val_left, since we're out of right
            # IO.inspect(val_left, label: "taking val_left since we're out of right")
            {insertion_idx + 1, idx_right, :array.set(insertion_idx, val_left, acc)}

          _idx_left, val_left, {insertion_idx, idx_right, acc} ->
            # Take as many from the right as are smaller than val_left, then val_left
            {acc, new_idx_right, new_insertion_idx} =
              take_until_greater_or_equal(
                right,
                val_left,
                acc,
                insertion_idx,
                idx_right,
                right_size
              )

            # IO.inspect(new_insertion_idx - insertion_idx,
            #   label: "took from right"
            # )

            updated_acc = :array.set(new_insertion_idx, val_left, acc)
            # IO.inspect(:array.to_list(updated_acc), label: "updated_acc")

            {new_insertion_idx + 1, new_idx_right, updated_acc}
        end,
        {0, 0, acc},
        left
      )

    # IO.inspect(:array.to_list(merged), label: "merged")

    fully_merged = take_all(right, idx_right, right_size, merged, insertion_idx)

    # IO.inspect(:array.to_list(fully_merged), label: "fully_merged")
    fully_merged
  end

  defp take_all(arr, start_idx, size, acc, insertion_idx) when start_idx < size do
    val = :array.get(start_idx, arr)
    acc = :array.set(insertion_idx, val, acc)
    take_all(arr, start_idx + 1, size, acc, insertion_idx + 1)
  end

  defp take_all(_arr, _start_idx, _size, acc, _insertion_idx), do: acc

  defp take_until_greater_or_equal(take_from, less_than_val, acc, insertion_idx, check_idx, size) do
    val = :array.get(check_idx, take_from)

    # IO.inspect(val < less_than_val,
    #   label: "val #{inspect(val)} < less_than_val #{inspect(less_than_val)}?"
    # )

    if val < less_than_val do
      acc = :array.set(insertion_idx, val, acc)
      check_next = check_idx + 1

      if check_next < size do
        take_until_greater_or_equal(
          take_from,
          less_than_val,
          acc,
          insertion_idx + 1,
          check_next,
          size
        )
      else
        {acc, check_next, insertion_idx + 1}
      end
    else
      {acc, check_idx, insertion_idx}
    end
  end

  def concat(array1, array2) do
    left_size = :array.size(array1)
    right_size = :array.size(array2)
    full = :array.resize(left_size + right_size, array1)

    Enum.reduce(0..(right_size - 1), full, fn idx, acc ->
      val = :array.get(idx, array2)
      :array.set(left_size + idx, val, acc)
    end)
  end

  # TODO: Don't make copies here; just note the indices and
  # pass them around like Swift does with array slices!
  def halve_arr(array, size) do
    split_point = div(size, 2)
    left = :array.resize(split_point, array)

    right_size = size - split_point

    right =
      Enum.reduce(0..(right_size - 1), :array.new(right_size), fn idx, acc ->
        val = :array.get(split_point + idx, array)
        :array.set(idx, val, acc)
      end)

    {left, right}
  end
end
