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
Transpiles a call. Traps some dunder names, like __mc__.
"""
function transpilecall(t)
    if pytypeof(t[:func]) == ast.Name
        @match t[:func][:id] begin
            "__jl__" => begin
                @assert length(t[:args]) == 1
                @assert pyisinstance(t[:args][1], ast.Str)
                parse(t[:args][1][:s])
            end
            "__mc__" => begin
                @assert length(t[:args]) ≥ 1
                mac = t[:args][1]
                args = t[:args][2:end]
                @assert pyisinstance(t[:args][1], ast.Name)
                Expr(:macrocall,
                    Symbol('@', jlident(mac[:id])),
                    transpile.(t[:args][2:end])...)
            end
            _ => transpilerawcall(t)
        end
    else
        transpilerawcall(t)
    end
end
