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
    # so range includes 1 and has length n — very different from Python.
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

## Rewriting
Some identifiers are rewritten. Currently, the only rewriting is that `_b` suffixes in Python get mapped to `!` suffixes in Julia.

## Magic Syntax

`PythonSyntax` introduces some magic syntax that is unlike anything else in the Python language.

 * `__jl__("2:2:10")` escapes to Julia syntax. This can be useful if something has no clean way of being expressed pythonically. Note that this is not a runtime method: only string literals, and not strings computed at runtime, can be used.
 * `__mc__(time, [i**2 for i in range(1, 10)])` allows calling Julia macros. Any number of arguments can be provided; they are given to the macro as expressions and are not evaluated, exactly as in Julia.
