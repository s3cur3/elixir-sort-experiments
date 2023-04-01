defmodule ArraySortTest do
  use ExUnit.Case, async: true
  import ArraySort, only: [merge_sort: 1, halve_arr: 2, concat: 2]

  @tag benchmark: true
  test "extremely rough benchmark" do
    sorted = Enum.to_list(1..10_000)
    to_sort = sorted |> Enum.shuffle()

    {list_ns, _} = :timer.tc(fn -> Enum.sort(to_sort) end)
    {array_ns, _} = :timer.tc(fn -> merge_sort(to_sort) end)

    IO.inspect(array_ns, label: "array_ns")
    IO.inspect(list_ns, label: "list_ns")
  end

  test "sorts a big list" do
    for range <- [1..10_000, 1..9_999] do
      sorted = Enum.to_list(range)
      to_sort = sorted |> Enum.shuffle()
      assert merge_sort(to_sort) == sorted
    end
  end

  test "sorts a list of length 3" do
    for to_sort <- [[1, 2, 3], [3, 2, 1], [1, 3, 2], [2, 3, 1], [3, 1, 2], [2, 1, 3]] do
      assert merge_sort(to_sort) == [1, 2, 3]
    end
  end

  test "sorts a list of length 11" do
    to_sort = [11, 10, 5, 4, 8, 3, 7, 1, 6, 9, 2]
    assert merge_sort(to_sort) == Enum.to_list(1..11)
  end

  test "sorts a small list" do
    for range <- [1..11, 1..10, 1..5, 1..4, 1..3, 1..2, [1], []] do
      sorted = Enum.to_list(range)
      to_sort = sorted |> Enum.shuffle()
      assert merge_sort(to_sort) == sorted
    end
  end

  test "halve_arr size 2" do
    to_halve =
      1..2
      |> Enum.to_list()
      |> :array.from_list()

    {left, right} = halve_arr(to_halve, 2)
    assert :array.to_list(left) == [1]
    assert :array.to_list(right) == [2]
  end

  test "halve_arr size 3" do
    to_halve =
      1..3
      |> Enum.to_list()
      |> :array.from_list()

    {left, right} = halve_arr(to_halve, 3)
    assert :array.to_list(left) == [1]
    assert :array.to_list(right) == [2, 3]
  end

  test "halve_arr size 4" do
    to_halve =
      1..4
      |> Enum.to_list()
      |> :array.from_list()

    {left, right} = halve_arr(to_halve, 4)
    assert :array.to_list(left) == [1, 2]
    assert :array.to_list(right) == [3, 4]
  end

  test "concat size 4" do
    l = :array.from_list([1, 2])
    r = :array.from_list([3, 4])
    joined = concat(l, r)
    assert :array.to_list(joined) == [1, 2, 3, 4]
  end
end
