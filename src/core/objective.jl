""
function objective_c1_variable_pg_cost(pm::_PM.AbstractPowerModel; kwargs...)
    model = _PM.check_gen_cost_models(pm)

    if model == 1
        return _PM.objective_variable_pg_cost(pm; kwargs...)
    elseif model == 2
        return objective_variable_pg_cost_polynomial_linquad(pm; kwargs...)
    else
        Memento.error(_LOGGER, "Only cost models of types 1 and 2 are supported at this time, given cost model type of $(model)")
    end

end

""
function objective_c1_variable_pg_cost_basecase(pm::_PM.AbstractPowerModel; kwargs...)
    model = _PM.check_gen_cost_models(pm)

    if model == 1
        return objective_c1_variable_pg_cost_basecase_pwl(pm; kwargs...)
    elseif model == 2
        return objective_c1_variable_pg_cost_basecase_polynomial_linquad(pm; kwargs...)
    else
        Memento.error(_LOGGER, "Only cost models of types 1 and 2 are supported at this time, given cost model type of $(model)")
    end

end
