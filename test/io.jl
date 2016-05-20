@testset "IO" begin

@test pysyntax"""
s = IOBuffer()
x = False
y = True
if x:
    println(s, "x is True")
elif y:
    println(s, "y is True")
else:
    println(s, "neither")

takebuf_string(s)
""" == "y is True\n"

@test pysyntax"""
s = IOBuffer()
show(s, [1, 2, 3])

takebuf_string(s)
""" == "[1,2,3]"

# FizzBuzz!
@test pysyntax"""
s = IOBuffer()
for i in range(1, 10):
    if i % 15 == 0:
        println(s, "FizzBuzz")
    elif i % 3 == 0:
        println(s, "Fizz")
    elif i % 5 == 0:
        println(s, "Buzz")
    else:
        println(s, i)
takebuf_string(s)
""" == """
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
"""

end  # testset
