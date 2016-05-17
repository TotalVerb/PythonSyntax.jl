module PythonSyntax

using PyCall
using Match

@pyimport ast

include("symbol.jl")
include("ops.jl")
include("function.jl")
include("class.jl")

export pyparse, @pysyntax_str, @pymodule_str


function transpileassign(t, aug=:(=))
    targets = transpile.(t[:targets])
    lhs = if length(targets) == 1
        targets[1]
    else
        Expr(:tuple, targets...)
    end

    Expr(:(=), lhs, transpile(t[:value]))
end


function transpilefor(t)
    if length(t[:orelse]) > 0
        error("PythonSyntax cannot currently handle else for loops.")
    end
    quote
        for $(transpile(t[:target])) in $(transpile(t[:iter]))
            $(transpile(t[:body]))
        end
    end
end

function transpilewhile(t)
    if length(t[:orelse]) > 0
        error("PythonSyntax cannot currently handle else for loops.")
    end
    quote
        while $(transpile(t[:test]))
            $(transpile(t[:body]))
        end
    end
end

function transpilewith(t)
    # FIXME: support
    error("PythonSyntax does not yet support with.")
end

function transpileraise(t)
    if t[:exc] == nothing
        quote error() end
    else
        quote throw($(transpile(t[:exc]))) end
    end
end

function transpiletry(t)
    # FIXME: support
    error("PythonSyntax does not yet support try.")
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

function transpile(s::Symbol, t::Vector)
    Expr(s, transpile.(t)...)
end

function transpile(t::PyObject)
    Tup = ast.pymember(:Tuple)
    @match pytypeof(t) begin
        ast.Module || ast.Interactive || ast.Expression ||
            ast.Suite => transpile(t[:body])
        ast.FunctionDef => transpilefn(t, jlident(t[:name]))
        ast.AsyncFunctionDef => transpilefn(t, jlident(t[:name]))  # FIXME: async
        ast.ClassDef => transpilecls(t)
        ast.Return => Expr(:return, transpile(t[:value]))
        ast.Delete => error("Delete not yet supported.")
        ast.Assign => transpileassign(t)
        ast.AugAssign => transpileassign(t, jlaugop(t[:op]))
        ast.For => transpilefor(t)
        ast.AsyncFor => transpilefor(t)  # FIXME: async
        ast.While => transpilewhile(t)
        ast.If || ast.IfExp => quote
            if $(transpile(t[:test]))
                $(transpile(t[:body]))
            else
                $(transpile(t[:orelse]))
            end
        end
        ast.With => transpilewith(t)
        ast.AsyncWith => transpilewith(t)  # FIXME: async
        ast.Raise => transpileraise(t)
        ast.Try => transpiletry(t)
        ast.Assert => if t[:msg] == nothing
            quote @assert $(transpile(t[:test])) end
        else
            quote @assert $(transpile(t[:test])) $(transpile(t[:msg])) end
        end
        # FIXME: add support for Import
        ast.Import || ast.ImportFrom => error("Import is not yet supported.")
        ast.Global || ast.Nonlocal => quote
            global $(Symbol.(t[:names])...)
        end
        ast.Expr => transpile(t[:value])
        ast.Pass => :( nothing )
        ast.Break => :( break )
        ast.Continue => :( continue )
        # Expressions
        ast.BoolOp => Expr(jlboolop(t[:op]), transpile.(t[:values])...)
        ast.BinOp => Expr(:call, jlop(t[:op]), transpile(t[:left]),
                transpile(t[:right]))
        ast.UnaryOp => Expr(:call, jlop(t[:op]), transpile(t[:operand]))
        ast.Lambda => transpilefn(t)
        ast.Dict => :(Dict(zip($(transpile(:vect, t[:keys])),
                $(transpile(:vect, t[:values])))))
        ast.Set => :(Set($(transpile(:vect, t[:elts]))))
        ast.ListComp || ast.SetComp || ast.DictComp || ast.GeneratorExp =>
            error("Comprehensions are not yet supported.")
        ast.Await || ast.Yield || ast.YieldFrom =>
            error("Generators are not yet supported.")
        ast.Compare => transpilecmp(t)
        # FIXME: keyword arguments
        ast.Call => transpilecall(t)
        ast.Num => t[:n]
        ast.Str => t[:s]
        ast.Bytes => t[:s]
        ast.NameConstant => t[:value]
        ast.Ellipsis => error("Ellipsis not yet supported.")
        ast.Attribute => Expr(:., transpile(t[:value]),
                Expr(:quote, jlident(t[:attr])))
        ast.Subscript => Expr(:ref, transpile(t[:value]),
                transpileslice(t[:slice])...)
        ast.Starred => Expr(:(...), transpile(t[:value]))
        ast.Name => jlident(t[:id])
        ast.List => transpile(:vect, t[:elts])
        Tup => transpile(:tuple, t[:elts])
    end
end

transpile(t::Vector) = Expr(:block, transpile.(t)...)

pyparse(s::AbstractString) = transpile(ast.parse(s))

macro pysyntax_str(str)
    pyparse(str) |> esc
end

macro pymodule_str(str)
    lines = split(str, '\n')
    name = jlident(lines[1])
    expr = pyparse(join(lines[2:end], '\n'))
    quote
        const $name = Module($(Expr(:quote, name)), true)
        eval($name, :( importall Base.Operators ))
        eval($name, $(Expr(:quote, expr)))
    end |> esc
end

end  # module Python Syntax