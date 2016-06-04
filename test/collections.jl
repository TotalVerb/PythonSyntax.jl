@testset "Arrays" begin

@test pysyntax"[1, 2, 3]" == [1, 2, 3]
@test pysyntax"[i for i in range(1, 10)]" == collect(1:10)

end  # testset Arrays

@testset "Sets" begin

@test pysyntax"{1, 1, 1, 2}" == Set([1, 2])
@test pysyntax"{i**2 for i in range(-5, 11)}" == Set([0, 1, 4, 9, 16, 25])

end  # testset Sets

@testset "Dicts" begin

@test pysyntax"{1: 2, 2: 3}" == Dict(1 => 2, 2 => 3)
@test pysyntax"{'hello': 'world'}" == Dict("hello" => "world")
@test pysyntax"{i: i**2 for i in range(1, 10)}" == Dict(i => i^2 for i in 1:10)

end  # testset Dicts
