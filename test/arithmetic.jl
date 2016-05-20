@testset "Arithmetic" begin

@test pysyntax"10" == 10
@test pysyntax"+10" == 10
@test pysyntax"-10" == -10

@test pysyntax"1 + 2" == 3
@test pysyntax"1 - 2" == -1
@test pysyntax"8 * 5" == 40
@test pysyntax"2 ** 5" == 32
@test pysyntax"10 // 3" == 3

end  # testset
