"""Return Julia version of Python operator."""
function jlop(t)
    @match pytypeof(t) begin
        ast.Add => :(+)
        ast.Sub => :(-)
        ast.Mult => :(*)
        ast.MatMult => :(*)
        ast.Div => :(/)
        ast.Mod => :(%)       # FIXME: mod?
        ast.Pow => :(^)
        ast.LShift => :(<<)
        ast.RShift => :(>>)
        ast.BitOr => :(|)
        ast.BitXor => :($)
        ast.BitAnd => :(&)
        ast.FloorDiv => :(÷)  # FIXME: fld?

        ast.Invert => :(~)
        ast.Not => :(!)
        ast.UAdd => :(+)
        ast.USub => :(-)
        ast.Eq => :(==)
        ast.NotEq => :(≠)
        ast.Lt => :(<)
        ast.LtE => :(≤)
        ast.Gt => :(>)
        ast.GtE => :(≥)
        ast.Is => :(≡)
        ast.IsNot => :(≢)
        ast.In => :(∈)
        ast.NotIn => :(∉)
        _ => error("Unsupported operation $(pytypeof(t))")
    end
end

"""Return Julia augmented version of Python operator."""
function jlaugop(t)
    jlident(jlop(t), :(=))
end

"""Return symbol for Julia boolean operator."""
function jlboolop(t)
    @match pytypeof(t) begin
        ast.And => :(&&)
        ast.Or => :(||)
    end
end
