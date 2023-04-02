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

  @spec to_list(t() | :array.array()) :: list()
  def to_list(%__MODULE__{} = slice) do
    slice
    |> reify()
    |> :array.to_list()
  end

  def to_list(array), do: :array.to_list(array)

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

  @spec merge(:array.array() | t(), :array.array() | t()) :: :array.array()
  def merge(
        %__MODULE__{array: array_l, base_idx: base_idx_l, end_idx: end_idx_l},
        %__MODULE__{end_idx: end_idx_r} = right
      ) do
    acc = :array.new()

    {right, merged, insertion_idx} =
      Enum.reduce(base_idx_l..(end_idx_l - 1), {right, acc, 0}, fn
        idx_left, {%__MODULE__{base_idx: idx_right} = right, acc, insertion_idx} when idx_right < end_idx_r ->
          val_left = :array.get(idx_left, array_l)
          # Take as many from the right as are smaller than val_left, then val_left
          {acc, right, new_insertion_idx} =
            take_while_less_than(
              %{right | base_idx: idx_right},
              val_left,
              acc,
              insertion_idx
            )

          updated_acc = :array.set(new_insertion_idx, val_left, acc)
          {right, updated_acc, new_insertion_idx + 1}

        idx_left, {right, acc, insertion_idx} ->
          # Take val_left, since we're out of right
          val_left = :array.get(idx_left, array_l)
          {right, :array.set(insertion_idx, val_left, acc), insertion_idx + 1}
      end)

    take_all(right, merged, insertion_idx)
  end

  def merge(left, %__MODULE__{} = right), do: merge(new(left), right)
  def merge(%__MODULE__{} = left, right), do: merge(left, new(right))
  def merge(left, right), do: merge(new(left), new(right))

  @spec take_all(t(), :array.array(), integer) :: :array.array()
  defp take_all(%__MODULE__{array: arr, base_idx: base_idx, end_idx: end_idx} = slice, acc, insertion_idx)
       when base_idx < end_idx do
    val = :array.get(base_idx, arr)
    acc = :array.set(insertion_idx, val, acc)
    take_all(%{slice | base_idx: base_idx + 1}, acc, insertion_idx + 1)
  end

  defp take_all(_slice, acc, _insertion_idx), do: acc

  @spec take_while_less_than(t(), any, :array.array(), integer) :: {:array.array(), t(), integer}
  defp take_while_less_than(
         %__MODULE__{array: arr, base_idx: check_idx, end_idx: end_idx} = slice,
         less_than_val,
         acc,
         insertion_idx
       ) do
    val = :array.get(check_idx, arr)

    if val < less_than_val do
      acc = :array.set(insertion_idx, val, acc)
      check_next = check_idx + 1
      updated_slice = %{slice | base_idx: check_next}

      if check_next < end_idx do
        take_while_less_than(updated_slice, less_than_val, acc, insertion_idx + 1)
      else
        {acc, updated_slice, insertion_idx + 1}
      end
    else
      {acc, slice, insertion_idx}
    end
  end
end
