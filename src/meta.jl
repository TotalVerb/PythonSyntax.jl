using Base.Meta

typealias Collection Union{AbstractArray, Set, Associative}

f ∘ A::Collection = map(f, A)
f ∘ g = x -> f(g(x))

"""
Simplify an expression by removing unnecessary `begin` blocks.
"""
function simplify(ex)
    if Meta.isexpr(ex, :block)
        if length(ex.args) == 1
            simplify(ex.args[1])
        else
            Expr(:block, simplify_flatten(ex.args)...)
        end
    else
        ex
    end
end

function simplify_flatten(args::Vector)
    newargs = []
    for a in simplify ∘ args
        if Meta.isexpr(a, :block)
            append!(newargs, a.args)
        else
            push!(newargs, a)
        end
    end
    newargs
end
