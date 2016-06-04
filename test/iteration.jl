@testset "Iteration" begin

@test pysyntax"sum(i**2 for i in range(1, 10))" == 385
@test pysyntax"""
collect(i + j for i in range(1, 2) for j in range(1, 2))
""" == [2 3; 3 4]

end  # testset Iteration
