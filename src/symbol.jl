import Base: /

word::AbstractString / suffix::AbstractString =
        String(convert(Vector{Char}, word)[1:end-length(suffix)])

const DUNDER = Dict(
        "__eq__" => :(==),
        "__ne__" => :(≠),
        "__lt__" => :(isless),
        "__gt__" => :(>),
        "__le__" => :(≤),
        "__ge__" => :(≥),
        "__pos__" => :(+),
        "__neg__" => :(-),
        "__abs__" => :abs,
        "__invert__" => :(~),
        "__round__" => :round,
        "__floor__" => :floor,
        "__ceil__" => :ceil,
        "__trunc__" => :trunc,
        "__add__" => :(+),
        "__sub__" => :(-),
        "__mul__" => :(*),
        "__floordiv__" => :(÷),
        "__div__" => :(/),
        "__mod__" => :(%),
        "__divmod__" => :divmod,
        "__pow__" => :(^),
        "__lshift__" => :(<<),
        "__rshift__" => :(>>),
        "__and__" => :(&),
        "__or__" => :(|),
        "__xor__" => :($)
        )

"""
Convert a Python identifier to its Julia equivalent.

Note that a `_b` suffix is mapped to `!`.
"""
jlident(name) = if haskey(DUNDER, name)
    DUNDER[name]
elseif ismatch(r"_b$", name)
    Symbol(name / "_b" * "!")
else
    Symbol(name)
end
