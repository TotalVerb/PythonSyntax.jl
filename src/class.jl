"""
Return a `Set{Symbol}` of suspected field names used for a Python class.
"""
function guessfields(t::PyObject)
    @match pytypeof(t) begin
        ast.Module || ast.Interactive || ast.Expression || ast.Suite =>
            guessfields(t[:body])
        ast.FunctionDef || ast.AsyncFunctionDef || ast.Lambda =>
            guessfields(t[:body])
        ast.ClassDef => guessfields(t[:body])
        ast.Return => guessfields(t[:value])
        ast.Delete => guessfields(t[:targets])
        ast.Assign => guessfields(t[:targets]) ∪ guessfields(t[:value])
        ast.AugAssign => guessfields(t[:target]) ∪ guessfields(t[:value])
        ast.For || ast.AsyncFor => guessfields(t[:target]) ∪
            guessfields(t[:iter]) ∪ guessfields(t[:body]) ∪
            guessfields(t[:orelse])
        ast.While || ast.If || ast.IfExp => guessfields(t[:test]) ∪
            guessfields(t[:body]) ∪ guessfields(t[:orelse])
        ast.With || ast.AsyncWith => guessfields(t[:items]) ∪
            guessfields(t[:body])
        ast.Raise => guessfields(t[:exc]) ∪ guessfields(t[:cause])
        ast.Try => guessfields(t[:body]) ∪ guessfields(t[:handlers]) ∪
            guessfields(t[:orelse]) ∪ guessfields(t[:finalbody])
        ast.Assert => guessfields(t[:test]) ∪ guessfields(t[:msg])
        ast.Import || ast.ImportFrom || ast.Global || ast.Nonlocal ||
            ast.Pass || ast.Break || ast.Continue => Set{Symbol}()
        ast.Expr || ast.Await || ast.Yield || ast.YieldFrom || ast.Starred ||
            ast.Index => guessfields(t[:value])
        ast.BoolOp => guessfields(t[:values])
        ast.BinOp => guessfields(t[:left]) ∪ guessfields(t[:right])
        ast.UnaryOp => guessfields(t[:operand])
        # ast.Lambda, ast.IfExp see above
        ast.Dict => guessfields(t[:keys]) ∪ guessfields(t[:values])
        ast.Set, ast.List, ast.Tuple => guessfields(t[:elts])
        ast.ListComp || ast.SetComp || ast.GeneratorExp =>
            guessfields(t[:elt]) ∪ guessfields(t[:generators])
        ast.DictComp => guessfields(t[:keys]) ∪ guessfields(t[:value]) ∪
            guessfields(t[:generators])
        # ast.Await, Yield, YieldFrom above
        ast.Compare => guessfields(t[:left]) ∪ guessfields(t[:comparators])
        ast.Call => guessfields(t[:func]) ∪ guessfields(t[:args]) ∪
            guessfields(t[:keywords])
        ast.Num || ast.Str || ast.Bytes || ast.NameConstant || ast.Ellipsis ||
            ast.Name => Set{Symbol}()
        ast.Attribute => guessfields(t[:value]) ∪
            if pyisinstance(t[:value], ast.Name) && t[:value][:id] == "self"
                Set([jlident(t[:attr])])
            else
                Set{Symbol}()
            end
        ast.Subscript => guessfields(t[:value]) ∪ guessfields(t[:slice])
        # ast.Starred, Name, List, Tuple, Index above
        ast.Slice => guessfields(t[:lower]) ∪ guessfields(t[:upper]) ∪
            guessfields(t[:step])
        ast.ExtSlice => guessfields(t[:dims])
        ast.comprehension => guessfields(t[:target]) ∪ guessfields(t[:iter]) ∪
            guessfields(t[:ifs])
        ast.ExceptHandler => guessfields(t[:type]) ∪ guessfields(t[:body])
        ast.withitem => guessfields(t[:context_expr])
        _ => Set{Symbol}()
    end
end

guessfields(::Void) = Set{Symbol}()

function guessfields(t::Vector)
    reduce(∪, Set{Symbol}(), map(guessfields, t))
end

"""
Determine whether the given `ast.AST` is a constructor.
"""
isconstructor(t) = pyisinstance(t, ast.FunctionDef) &&
        t[:name] == "__init__"

"""
Determine whether the given `ast.AST` is a method.
"""
ismethod(t) = pyisinstance(t, ast.FunctionDef) && !isconstructor(t)

"""
Transpile a class constructor.
"""
function transpileinit(t, clsname)
    args, kw = transpileargs(t[:args])
    args = args[2:end]

    fnheader = header(clsname, args, kw)
    Expr(:function, fnheader, quote
        self = new()
        $(transpile(t[:body]))
        self
    end)
end

"""
Transpile a regular method.
"""
function transpilemethod(t, clsname)
    args, kw = transpileargs(t[:args])
    args[1] = annotate(args[1], clsname)

    fnheader = header(jlident(t[:name]), args, kw)
    Expr(:function, fnheader, transpile(t[:body]))
end

"""
Transpile a Python class into a Julia type.
"""
function transpilecls(t)
    if length(t[:decorator_list]) > 0
        error("PythonSyntax does not support decorators.")
    elseif length(t[:bases]) > 0
        error("PythonSyntax does not support inheritance.")
    elseif length(t[:keywords]) > 0
        error("PythonSyntax does not support keyword arguments for classes.")
    end

    clsname = jlident(t[:name])

    # Guess fields by using self.x as a heuristic for "we need this field"
    fields = sort(collect(guessfields(t)))

    # Get the inner constructors and body methods
    inner = map(x -> transpileinit(x, clsname), filter(isconstructor, t[:body]))
    body = map(x -> transpilemethod(x, clsname), filter(ismethod, t[:body]))

    quote
        type $clsname
            $(fields...)
            $(inner...)
        end
        $(body...)
    end
end
