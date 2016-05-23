#=
 = This file contains lightly ported portions of the Python standard library.
 = Please see LICENSE.md for copyright information.
 =#

@testset "StdLib" begin

# STL bisect
pysyntax"""
def insort_right(a, x, lo=1, hi=None):
    '''Insert item x in list a, and keep it sorted assuming a is sorted.

    If x is already in a, insert it to the right of the rightmost x.

    Optional args lo (default 0) and hi (default len(a)) bound the
    slice of a to be searched.
    '''
    if lo <= 0:
        raise ArgumentError('lo must be positive')

    if hi is None:
        hi = length(a) + 1

    while lo < hi:
        mid = (lo+hi)//2
        if x < a[mid]: hi = mid
        else: lo = mid+1

    insert_b(a, lo, x)

insort = insort_right   # backward compatibility

def bisect_right(a, x, lo=1, hi=None):
    '''Return the index where to insert item x in list a, assuming a is sorted.
    The return value i is such that all e in a[:i] have e <= x, and all e in
    a[i:] have e > x.  So if x already appears in the list, a.insert(x) will
    insert just after the rightmost x already there.

    Optional args lo (default 0) and hi (default len(a)) bound the
    slice of a to be searched.
    '''

    if lo < 1:
        raise ValueError('lo must be non-negative')

    if hi is None:
        hi = length(a) + 1

    while lo < hi:
        mid = (lo+hi)//2
        if x < a[mid]: hi = mid
        else: lo = mid+1

    return lo

# Tests
__mc__(test, insort_right([1, 2, 4, 5, 6], 3) == [1, 2, 3, 4, 5, 6])
__mc__(test, insort_right([1, 3, 4, 5, 6], 9) == [1, 3, 4, 5, 6, 9])
__mc__(test, insort_right([1, 5, 5, 5, 6], 0) == [0, 1, 5, 5, 5, 6])
__mc__(test, insort([], 1) == [1])
"""

end
