# Elixir Sorting Experiments

This was an experiment with speeding up sorting Elixir lists.

My hypothesis was that moving to a structure that was more
compact in memory (first I thought tuples, then quickly moved
on to [`:array.array()`][1]) would be more efficient overall than
doing a merge sort on lists, as Erlang's [`:list.sort/1`][2] and
thus Elixir's [`Enum.sort/1`][3] do under the hood.

(See [`ArraySort`](lib/array_sort.ex) for the core, and
[`ArraySlice`](lib/array_slice.ex) for the structure I used
to cut down a bit on copies.)

Boy was I wrong!

Comparing a list of 10,000 elements, the current implementation
is about 15&times; slower than `Enum.sort/1` on a list. And that's
pretty much the best case scenario—at size 100, this one is 2,250&times;
slower than the list version (presumably because at large sizes,
we amortize the cost of going to an array from a list, then back 
again at the end).

The fundamental problem I ran into is that, while Erlang's `:array`
does some clever things to prevent modifications in one place from
necessarily rewriting the whole structure (it's basically [a tree
structure with a fan-out of 10][4]), the way the merge step of a
merge sort works pretty much requires you to rewrite, on average,
10&times; the memory of a single item. `memcpy` is fast, but not
that fast.

It'd be interesting to see if it made a difference if you built an 
`:array`-like structure with a fanout of, say, 5. I'd also be 
interested to learn more about how the BEAM allocates lists under
the hood—it seems like small allocation made within the same 
millisecond tend to have pretty darn good [memory locality][5],
even though they aren't guaranteed to do so.

[1]: https://erlang.org/doc/man/array.html
[2]: https://github.com/erlang/otp/blob/master/lib/stdlib/src/lists.erl#L642
[3]: https://github.com/elixir-lang/elixir/blob/2601929a4437b5db077ac597f832c7061a6cdf7f/lib/elixir/lib/enum.ex#L3075
[4]: https://readreplica.io/functional-arrays-in-elixir-erlang/#tree-structure
[5]: https://en.wikipedia.org/wiki/Locality_of_reference
