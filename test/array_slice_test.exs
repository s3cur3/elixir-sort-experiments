defmodule ArraySliceTest do
  use ExUnit.Case, async: true

  test "halve size 2" do
    to_halve =
      1..2
      |> Enum.to_list()
      |> :array.from_list()

    {left, right} = ArraySlice.halve(to_halve, 2)
    assert left == %ArraySlice{array: to_halve, base_idx: 0, end_idx: 1, size: 1}
    assert right == %ArraySlice{array: to_halve, base_idx: 1, end_idx: 2, size: 1}
    assert ArraySlice.to_list(left) == [1]
    assert ArraySlice.to_list(right) == [2]
  end

  test "halve_arr size 3" do
    to_halve =
      1..3
      |> Enum.to_list()
      |> :array.from_list()

    {left, right} = ArraySlice.halve(to_halve, 3)
    assert left == %ArraySlice{array: to_halve, base_idx: 0, end_idx: 1, size: 1}
    assert right == %ArraySlice{array: to_halve, base_idx: 1, end_idx: 3, size: 2}
    assert ArraySlice.to_list(left) == [1]
    assert ArraySlice.to_list(right) == [2, 3]
  end

  test "halve_arr size 4" do
    to_halve =
      1..4
      |> Enum.to_list()
      |> :array.from_list()

    {left, right} = ArraySlice.halve(to_halve, 4)
    assert left == %ArraySlice{array: to_halve, base_idx: 0, end_idx: 2, size: 2}
    assert right == %ArraySlice{array: to_halve, base_idx: 2, end_idx: 4, size: 2}
    assert ArraySlice.to_list(left) == [1, 2]
    assert ArraySlice.to_list(right) == [3, 4]
  end
end
