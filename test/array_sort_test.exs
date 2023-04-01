defmodule ArraySortTest do
  use ExUnit.Case, async: true
  import ArraySort, only: [merge_sort: 1]

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
end
