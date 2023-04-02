defmodule ArraySlice do
  @moduledoc """
  A "view" over an array
  """
  @enforce_keys [:array, :base_idx, :end_idx, :size]
  defstruct @enforce_keys

  @type t :: %__MODULE__{array: :array.array(), base_idx: integer, end_idx: integer, size: integer}

  @spec new(:array.array(), integer, integer) :: t()
  def new(array, base_idx, end_idx) do
    %__MODULE__{array: array, base_idx: base_idx, end_idx: end_idx, size: end_idx - base_idx}
  end

  def new(array) do
    size = :array.size(array)
    %__MODULE__{array: array, base_idx: 0, end_idx: size, size: size}
  end

  @spec reify(t()) :: :array.array()
  def reify(%__MODULE__{array: array, base_idx: base_idx, end_idx: end_idx}) do
    cond do
      base_idx == 0 && :array.size(array) == end_idx ->
        array

      base_idx == 0 ->
        :array.resize(end_idx, array)

      true ->
        Enum.reduce(base_idx..(end_idx - 1), :array.new(), fn idx, acc ->
          val = :array.get(idx, array)
          :array.set(idx - base_idx, val, acc)
        end)
    end
  end

  @spec reify_list(t()) :: list()
  def reify_list(%__MODULE__{} = slice) do
    slice
    |> reify()
    |> :array.to_list()
  end

  @spec halve(t()) :: {t(), t()}
  def halve(%__MODULE__{array: array, base_idx: base_idx, end_idx: end_idx, size: size}) do
    split_point = div(size, 2)
    left = ArraySlice.new(array, base_idx, base_idx + split_point)
    right = ArraySlice.new(array, base_idx + split_point, end_idx)
    {left, right}
  end

  @spec halve(:array.array(), integer) :: {t(), t()}
  def halve(array, size) do
    split_point = div(size, 2)
    left = new(array, 0, split_point)
    right = new(array, split_point, size)
    {left, right}
  end

  @spec merge(:array.array() | t(), :array.array() | t(), :array.array()) :: :array.array()
  def merge(left, right, acc \\ :array.new())

  @spec merge(t(), t(), :array.array()) :: :array.array()
  def merge(
        %__MODULE__{array: array_l, base_idx: base_idx_l, end_idx: end_idx_l} = left,
        %__MODULE__{array: array_r, base_idx: base_idx_r, end_idx: end_idx_r} = right,
        acc
      ) do
    # IO.inspect(reify_list(left), label: "merging left", charlists: :as_lists)
    # IO.inspect(reify_list(right), label: "merging right", charlists: :as_lists)

    {insertion_idx, idx_right, merged} =
      Enum.reduce(base_idx_l..(end_idx_l - 1), {0, base_idx_r, acc}, fn
        idx_left, {insertion_idx, idx_right, acc} when idx_right < end_idx_r ->
          val_left = :array.get(idx_left, array_l)
          # Take as many from the right as are smaller than val_left, then val_left
          {acc, new_idx_right, new_insertion_idx} =
            take_until_greater_or_equal(
              array_r,
              idx_right,
              end_idx_r,
              val_left,
              acc,
              insertion_idx
            )

          # IO.inspect(new_insertion_idx - insertion_idx,
          #   label: "took from right"
          # )

          updated_acc = :array.set(new_insertion_idx, val_left, acc)
          # IO.inspect(:array.to_list(updated_acc), label: "updated_acc")

          {new_insertion_idx + 1, new_idx_right, updated_acc}

        idx_left, {insertion_idx, idx_right, acc} ->
          # Take val_left, since we're out of right
          val_left = :array.get(idx_left, array_l)
          # IO.inspect(val_left, label: "taking val_left since we're out of right")
          {insertion_idx + 1, idx_right, :array.set(insertion_idx, val_left, acc)}
      end)

    # IO.inspect(:array.to_list(merged), label: "merged")

    fully_merged = take_all(array_r, idx_right, end_idx_r, merged, insertion_idx)
    # IO.inspect(:array.to_list(fully_merged), label: "fully_merged")
    fully_merged
  end

  def merge(left, %__MODULE__{} = right, acc), do: merge(new(left), right, acc)
  def merge(%__MODULE__{} = left, right, acc), do: merge(left, new(right), acc)
  def merge(left, right, acc), do: merge(new(left), new(right), acc)

  @spec take_all(:array.array(), integer, integer, :array.array(), integer) :: :array.array()
  defp take_all(arr, base_idx, end_idx, acc, insertion_idx)
       when base_idx < end_idx do
    val = :array.get(base_idx, arr)
    acc = :array.set(insertion_idx, val, acc)
    take_all(arr, base_idx + 1, end_idx, acc, insertion_idx + 1)
  end

  defp take_all(_arr, _, _, acc, _insertion_idx), do: acc

  @spec take_until_greater_or_equal(:array.array(), integer, integer, any, :array.array(), integer) ::
          {:array.array(), integer, integer}
  defp take_until_greater_or_equal(
         arr,
         check_idx,
         end_idx,
         less_than_val,
         acc,
         insertion_idx
       ) do
    val = :array.get(check_idx, arr)

    # IO.inspect(val < less_than_val,
    #   label: "val #{inspect(val)} < less_than_val #{inspect(less_than_val)}?"
    # )

    if val < less_than_val do
      acc = :array.set(insertion_idx, val, acc)
      check_next = check_idx + 1

      if check_next < end_idx do
        take_until_greater_or_equal(
          arr,
          check_next,
          end_idx,
          less_than_val,
          acc,
          insertion_idx + 1
        )
      else
        {acc, check_next, insertion_idx + 1}
      end
    else
      {acc, check_idx, insertion_idx}
    end
  end
end
