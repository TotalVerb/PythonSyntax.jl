@testset "Magic" begin

@test pysyntax"""
def goto():
    __mc__(goto, skip)
    return False
    __mc__(label, skip)
    return True

goto()
"""

@test pysyntax"""
def goto():
    __jl__("@goto skip")
    return False
    __jl__("@label skip")
    return True

goto()
"""

end  # testset
