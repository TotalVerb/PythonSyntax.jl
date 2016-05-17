@testset "Functions" begin

@test pysyntax"""
def fib(x):
    if x < 2:
        return x
    else:
        return fib(x-1) + fib(x-2)

fib(10)
""" == 55

@test pysyntax"""
def fun(x: Integer):
    return "x is an integer"

def fun(x: AbstractFloat):
    return "x is a floating-point number"

fun(1), fun(1.0)
""" == ("x is an integer", "x is a floating-point number")

end  # testset
