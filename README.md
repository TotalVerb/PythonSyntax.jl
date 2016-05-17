# PythonSyntax

[![Build Status](https://travis-ci.org/TotalVerb/PythonSyntax.jl.svg?branch=master)](https://travis-ci.org/TotalVerb/PythonSyntax.jl)

[![Coverage Status](https://coveralls.io/repos/TotalVerb/PythonSyntax.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/TotalVerb/PythonSyntax.jl?branch=master)

[![codecov.io](http://codecov.io/github/TotalVerb/PythonSyntax.jl/coverage.svg?branch=master)](http://codecov.io/github/TotalVerb/PythonSyntax.jl?branch=master)

This package is under heavy development and anything might change at any time. It also currently doesn't work on any release version of Julia. A nightly build is required in the meantime.

PythonSyntax.jl is a little like [LispSyntax.jl](https://github.com/swadey/LispSyntax.jl), where this package gets its inspiration. But this isn't lisp syntax, it's Python syntax.

The easiest way to use this package is to define modules:

```julia
using PythonSyntax

pymodule"""
FizzBuzz

def fizzbuzz(n):
    # this is still Julia, even though it looks like Python!
    # so range includes both endpoints
    for i in range(1, n):
        if i % 15 == 0:
            println("FizzBuzz")
        elif i % 3 == 0:
            println("Fizz")
        elif i % 5 == 0:
            println("Buzz")
        else:
            println(i)
"""

FizzBuzz.fizzbuzz(10)
```

Remember: this is Julia, not Python. The syntax is Pythonic but the semantics are Julian.
