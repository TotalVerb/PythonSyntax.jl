@testset "Control" begin

@test pysyntax"1 if True else 0" == 1
@test pysyntax"1 if False else 0" == 0

@test pysyntax"
x = 1
if 1 + 1 == 2:
    x *= 3
x" == 3

@test pysyntax"
x = 1
if 1 + 1 == 2:
    x *= 3
x" == 3
end  # testset
