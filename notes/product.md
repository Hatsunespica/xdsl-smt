# Coalessed product vs. Reduced product

Consider the domains of signed and unsigned integer ranges, where neither range wraps.
The only difference between the domains is how they interprent the underlying bitvectors (as signed or unsigned).

Here are all possible 3-bit wide vectors, and their interpretations.

bitvector        | `000` | `001` | `010` | `011` | `100` | `101` | `110` | `111`
-----------------|-------|-------|-------|-------|-------|-------|-------|-------
signed interp    |   `0` |   `1` |   `2` |   `3` |   `4` |   `5` |   `6` |   `7`
unsigned interp  |   `0` |   `1` |   `2` |   `3` |  `-4` |  `-3` |  `-2` |  `-1`

Here are a few examples of concrete sets, and their corosponding abstractions

UCR: `\alpha({1,  2, 5}) = [1,  5]`
SCR: `\alpha({-1, 0, 3}) = [-1, 3]`

But note that since their is no wrapping, then any time a concrete set includes the least element and the greatest element
(which are different depending on how you choose to interpret the underlying bitvectors).
Then the abstract value must be top, i.e.

UCR: `\alpha({0,  7}) = [0,  7] = \top`
SCR: `\alpha({0,  7}) = [-1, 0]`

And conversly:

SCR: `\alpha({3, -4}) = [-4, 3] = \top`
UCR: `\alpha({3, -4}) = [3,  4]`

So now consider the following case for abstract addition over some concrete sets, and their corosponding abstract elements in each domain.

 domain  | lhs      | rhs         | res
---------|----------|-------------|-------------
concrete | `{4}`    | `{3, 4, 5}` | `{7, 0, 1}`
UCR      | `[4, 4]` | `[3, 5]`    | `\top`
SCR      | `[4, 4]` | `\top`      | `\top`

Doing the addition in both domains seperatly, then reducing their outputs will only yeild top.
In the case the UCR domain alone has enough information to calculate the result, but the result cannot be represended accuratly in UCR (because of the wraparound in the result).
And while the SCR domain could represent the result easily (`[-1, 1]`), it cannot represent the rhs, so it must just assume that the result is top.

However if we considered a transformer, that takes in all four values (lhs_ucr, lhs_scr, rhs_ucr, rhs_scr), and returns a result in both domains.
Then in theory this transformer could return `{UCR: \top, SCR: [-1, 1]}` as an optimal result.
