function transpileassign(t)
    targets = transpile.(t[:targets])
    lhs = if length(targets) == 1
        targets[1]
    else
        Expr(:tuple, targets...)
    end

    Expr(:(=), lhs, transpile(t[:value]))
end

function transpileaugassign(t)
    lhs = transpile(t[:target])
    op = jlaugop(t[:op])
    rhs = transpile(t[:value])
    Expr(op, lhs, rhs)
end


function transpilecmp(t)
    args = Any[transpile(t[:left])]
    for (op, val) in zip(t[:ops], t[:comparators])
        push!(args, jlop(op), transpile(val))
    end
    Expr(:comparison, args...)
end

function transpileslice(t)
    @match pytypeof(t) begin
        ast.Slice => [Expr(:(:),
                t[:lower] == nothing ? 1 : transpile(t[:lower]),
                t[:step] == nothing  ? 1 : transpile(t[:step]),
                t[:upper] == nothing ? :end : transpile(t[:upper]))]
        ast.ExtSlice => transpileslice.(t[:dims])
        ast.Index => [transpile(t[:value])]
    end
end

transpilerawcall(t) = Expr(:call, transpile(t[:func]), transpile.(t[:args])...)

"""
Transpiles a call. Traps some dunder names, like __jl_macro__.
"""
function transpilecall(t)
    if pytypeof(t[:func]) == ast.Name
        @match t[:func][:id] begin
            "__jlmc__" => Expr(:macrocall,
                    Symbol('@', jlident(t[:args][1][:id])),
                    transpile.(t[:args][2:end])...)
            _ => transpilerawcall(t)
        end
    else
        transpilerawcall(t)
    end
end
