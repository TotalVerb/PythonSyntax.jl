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
