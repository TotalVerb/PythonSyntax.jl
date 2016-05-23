@testset "Arrays" begin

@test pysyntax"[1, 2, 3]" == [1, 2, 3]
@test pysyntax"[i for i in range(1, 10)]" == collect(1:10)
@test pysyntax"{i**2 for i in range(-5, 11)}" == Set([0, 1, 4, 9, 16, 25])

end  # testset
