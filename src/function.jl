function kw(args)
    Expr(:parameters, args...)
end

var(args, ::Void) = args
var(args, vararg) = [args; [Expr(:(...), vararg)]]

header(args, kwargs) = Expr(:tuple, kw(kwargs), args...)
header(name, args, kwargs) = Expr(:call, name, kw(kwargs), args...)

transpilearg(::Void) = nothing

function transpilearg(arg)
    if arg[:annotation] == nothing
        jlident(arg[:arg])
    else
        Expr(:(::), jlident(arg[:arg]), transpile(arg[:annotation]))
    end
end

function transpilearg(arg, def)
    Expr(:kw, transpilearg(arg), transpile(def))
end

function annotate(arg::Symbol, note)
    Expr(:(::), arg, note)
end

function annotate(arg::Expr, note)
    if arg.head == :(::)
        arg
    elseif arg.head == :kw
        Expr(:kw, annotate(arg.args[1], note), arg.args[2])
    else
        error("Cannot annotate $(Meta.show_sexpr(arg)) with type $note.")
    end
end

function transpileargs(arguments)
    args = arguments[:args]
    kwargs = arguments[:kwonlyargs]
    vararg = arguments[:vararg]
    kwarg = arguments[:kwarg]
    defaults = arguments[:defaults]
    kw_defaults = arguments[:kw_defaults]

    if length(kwargs) ≠ length(kw_defaults)
        error("PythonSyntax requires all keyword arguments to have defaults.")
    end

    jlargs = var([transpilearg.(args[1:end-length(defaults)]);
                  transpilearg.(args[end-length(defaults)+1:end], defaults)],
            transpilearg(vararg))
    jlkwargs = var(transpilearg.(kwargs, kw_defaults), transpilearg(kwarg))
    jlargs, jlkwargs
end

function transpilefn(t, name::Symbol)
    if length(t[:decorator_list]) > 0
        error("PythonSyntax does not support decorators.")
    end

    fnbody = transpile(t[:body])
    if t[:returns] ≠ nothing
        fnbody = Expr(:(::), fnbody, transpile(t[:returns]))
    end

    a, kw = transpileargs(t[:args])
    fnheader = header(name, a, kw)
    Expr(:function, fnheader, fnbody)
end

function transpilefn(t)
    fnbody = transpile(t[:body])

    kw, a = transpileargs(t[:args])
    fnheader = header(a, kw)
    Expr(:function, fnheader, fnbody)
end
