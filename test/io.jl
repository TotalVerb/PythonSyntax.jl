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

end  # testset
