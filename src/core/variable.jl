
"variable controling a linear genetor responce "
function variable_c1_response_delta(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, report::Bool=true)
    delta = var(pm, nw)[:delta] = @variable(pm.model,
        base_name="$(nw)_delta",
        start = 0.0
    )

    if report
        sol(pm, nw)[:delta] = delta
    end
end


"generates variables for both `active` and `reactive` bus deltas"
function variable_bus_delta_abs(pm::_PM.AbstractPowerModel; kwargs...)
    variable_bus_delta_abs_power_real(pm; kwargs...)
    variable_bus_delta_abs_power_imaginary(pm; kwargs...)
end


""
function variable_bus_delta_abs_power_real(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    p_delta_abs = var(pm, nw)[:p_delta_abs] = @variable(pm.model,
        [i in ids(pm, :bus)], base_name="$(nw)_p_delta_abs",
        start = 0.0
    )

    if bounded
        for (i, bus) in ref(pm, nw, :bus)
            JuMP.set_lower_bound(p_delta_abs[i], 0.0)
            JuMP.set_upper_bound(p_delta_abs[i], 0.5)
        end
    end

    report && _PM.sol_component_value(pm, nw, :bus, :p_delta_abs, ids(pm, nw, :bus), p_delta_abs)
end

""
function variable_bus_delta_abs_power_imaginary(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
     q_delta_abs = var(pm, nw)[:q_delta_abs] = @variable(pm.model,
        [i in ids(pm, :bus)], base_name="$(nw)_q_delta_abs",
        start = 0.0
    )

    if bounded
        for (i, bus) in ref(pm, nw, :bus)
            JuMP.set_lower_bound(q_delta_abs[i], 0.0)
            JuMP.set_upper_bound(q_delta_abs[i], 0.5)
        end
    end

    report && _PM.sol_component_value(pm, nw, :bus, :q_delta_abs, ids(pm, nw, :bus), q_delta_abs)
end


""
function variable_c1_shunt_admittance_imaginary(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    bs = var(pm, nw)[:bs] = @variable(pm.model,
        [i in ids(pm, nw, :shunt_var)], base_name="$(nw)_bs",
        start = _PM.comp_start_value(ref(pm, nw, :shunt, i), "bs_start")
    )

    if bounded
        for i in ids(pm, nw, :shunt_var)
            shunt = ref(pm, nw, :shunt, i)
            JuMP.set_lower_bound(bs[i], shunt["bmin"])
            JuMP.set_upper_bound(bs[i], shunt["bmax"])
        end
    end

    report && _PM.sol_component_value(pm, nw, :shunt, :bs, ids(pm, nw, :shunt_var), bs)
end

""
function variable_c1_shunt_admittance_imaginary(pm::_PM.AbstractWModels; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    bs = var(pm, nw)[:bs] = @variable(pm.model,
        [i in ids(pm, nw, :shunt_var)], base_name="$(nw)_bs",
        start = _PM.comp_start_value(ref(pm, nw, :shunt, i), "bs_start")
    )

    wbs = var(pm, nw)[:wbs] = @variable(pm.model,
        [i in ids(pm, nw, :shunt_var)], base_name="$(nw)_wbs",
        start = 0.0
    )

    if bounded
        for i in ids(pm, nw, :shunt_var)
            shunt = ref(pm, nw, :shunt, i)
            JuMP.set_lower_bound(bs[i], shunt["bmin"])
            JuMP.set_upper_bound(bs[i], shunt["bmax"])
        end
    end

    report && _PM.sol_component_value(pm, nw, :shunt, :bs, ids(pm, nw, :shunt_var), bs)
    report && _PM.sol_component_value(pm, nw, :shunt, :wbs, ids(pm, nw, :shunt_var), wbs)
end


function variable_c1_branch_power_slack(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    sm_slack = var(pm, nw)[:sm_slack] = JuMP.@variable(pm.model,
        [l in ids(pm, nw, :branch_sm_active)], base_name="$(nw)_sm_slack",
        start = _PM.comp_start_value(ref(pm, nw, :branch, l), "sm_slack_start")
    )

    if bounded
        for (l,branch) in ref(pm, nw, :branch_sm_active)
            JuMP.set_lower_bound(sm_slack[l], 0.0)
            JuMP.set_upper_bound(sm_slack[l], 0.1)
        end
    end

    report && _PM.sol_component_value(pm, nw, :branch, :sm_slack, ids(pm, nw, :branch_sm_active), sm_slack)
end

function variable_c1_power_balance_slack(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    p_balance_slack = var(pm, nw)[:p_balance_slack] = JuMP.@variable(pm.model,
        [i in ids(pm, nw, :bus)], base_name="$(nw)_p_balance_slack",
        start = _PM.comp_start_value(ref(pm, nw, :bus, i), "p_balance_slack_start")
    )

    if bounded
        for (i,bus) in ref(pm, nw, :bus)
            JuMP.set_lower_bound(p_balance_slack[i], 0.0)
        end
    end

    report && _PM.sol_component_value(pm, nw, :bus, :p_balance_slack, ids(pm, nw, :bus), p_balance_slack)
end


function variable_c1_bus_voltage_magnitude_delta(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    vvm_delta = var(pm, nw)[:vvm_delta] = JuMP.@variable(pm.model,
        [i in ids(pm, nw, :bus)], base_name="$(nw)_vvm_delta",
        start = _PM.comp_start_value(ref(pm, nw, :bus, i), "vvm_delta_start", 0.1)
    )

    report && _PM.sol_component_value(pm, nw, :bus, :vvm_delta, ids(pm, nw, :bus), vvm_delta)
end


function variable_c1_gen_power_real_delta(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    pg_delta = var(pm, nw)[:pg_delta] = JuMP.@variable(pm.model,
        [i in ids(pm, nw, :gen)], base_name="$(nw)_pg_delta",
        start = _PM.comp_start_value(ref(pm, nw, :gen, i), "pg_delta_start", 0.1)
    )

    report && _PM.sol_component_value(pm, nw, :gen, :pg_delta, ids(pm, nw, :gen), pg_delta)
end



function variable_c1_branch_contigency_power_violation(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    branch_cont_flow_vio = var(pm, nw)[:branch_cont_flow_vio] = JuMP.@variable(pm.model,
        [i in 1:length(ref(pm, :branch_flow_cuts))], base_name="$(nw)_branch_cont_flow_vio",
        #start = _PM.comp_start_value(ref(pm, nw, :bus, i), "cont_branch_vio_start")
    )

    if bounded
        for i in 1:length(ref(pm, :branch_flow_cuts))
            JuMP.set_lower_bound(branch_cont_flow_vio[i], 0.0)
        end
    end

    #report && _PM.sol_component_value(pm, nw, :gen, :pg_delta, ids(pm, nw, :gen), pg_delta)
end


function variable_c1_gen_contigency_power_violation(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    gen_cont_flow_vio = var(pm, nw)[:gen_cont_flow_vio] = JuMP.@variable(pm.model,
        [i in 1:length(ref(pm, :gen_flow_cuts))], base_name="$(nw)_gen_cont_flow_vio",
        #start = _PM.comp_start_value(ref(pm, nw, :bus, i), "cont_branch_vio_start")
    )

    if bounded
        for i in 1:length(ref(pm, :gen_flow_cuts))
            JuMP.set_lower_bound(gen_cont_flow_vio[i], 0.0)
        end
    end

    #report && _PM.sol_component_value(pm, nw, :gen, :pg_delta, ids(pm, nw, :gen), pg_delta)
end


function variable_c1_gen_contigency_capacity_violation(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    gen_cont_cap_vio = var(pm, nw)[:gen_cont_cap_vio] = JuMP.@variable(pm.model,
        [i in 1:length(ref(pm, :gen_contingencies))], base_name="$(nw)_gen_cont_cap_vio",
        #start = _PM.comp_start_value(ref(pm, nw, :bus, i), "cont_branch_vio_start")
    )

    if bounded
        for i in 1:length(ref(pm, :gen_contingencies))
            JuMP.set_lower_bound(gen_cont_cap_vio[i], 0.0)
        end
    end

    #report && _PM.sol_component_value(pm, nw, :gen, :pg_delta, ids(pm, nw, :gen), pg_delta)
end


""
function variable_c2_load_power_factor_range(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, report::Bool=true)
    z_demand = var(pm, nw)[:z_demand] = JuMP.@variable(pm.model,
        [i in ids(pm, nw, :load)], base_name="$(nw)_z_demand",
        upper_bound = ref(pm, nw, :load, i)["tmax"],
        lower_bound = ref(pm, nw, :load, i)["tmin"],
        start = _PM.comp_start_value(ref(pm, nw, :load, i), "z_demand_start", 1.0)
    )

    if report
        _PM.sol_component_value(pm, nw, :load, :pf, ids(pm, nw, :load), z_demand)
        sol_pd = Dict(i => z_demand[i]*ref(pm, nw, :load, i)["pd_nominal"] for i in ids(pm, nw, :load))
        _PM.sol_component_value(pm, nw, :load, :pd, ids(pm, nw, :load), sol_pd)
        sol_qd = Dict(i => z_demand[i]*ref(pm, nw, :load, i)["qd_nominal"] for i in ids(pm, nw, :load))
        _PM.sol_component_value(pm, nw, :load, :qd, ids(pm, nw, :load), sol_qd)
    end
end

""
function variable_c2_branch_limit_slack(pm::_PM.AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    sm_slack = var(pm, nw)[:sm_slack] = JuMP.@variable(pm.model,
        [l in ids(pm, nw, :branch)], base_name="$(nw)_sm_slack",
        start = _PM.comp_start_value(ref(pm, nw, :branch, l), "sm_slack_start")
    )

    if bounded
        vio_ub = ref(pm, nw, :sm_vio_limit)
        for (l,branch) in ref(pm, nw, :branch)
            JuMP.set_lower_bound(sm_slack[l],    0.0)
            JuMP.set_upper_bound(sm_slack[l], vio_ub)
        end
    end

    report && _PM.sol_component_value(pm, nw, :branch, :sm_slack, ids(pm, nw, :branch), sm_slack)
end
