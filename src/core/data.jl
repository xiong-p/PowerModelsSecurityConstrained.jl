

"build a static ordering of all contingencies"
function contingency_order(network)
    gen_cont_order = sort(network["gen_contingencies"], by=(x) -> x.label)
    branch_cont_order = sort(network["branch_contingencies"], by=(x) -> x.label)

    gen_cont_total = length(gen_cont_order)
    branch_cont_total = length(branch_cont_order)

    gen_rate = 1.0
    branch_rate = 1.0
    steps = 1

    if gen_cont_total == 0 && branch_cont_total == 0
        # defaults are good
    elseif gen_cont_total == 0 && branch_cont_total != 0
        steps = branch_cont_total
    elseif gen_cont_total != 0 && branch_cont_total == 0
        steps = gen_cont_total
    elseif gen_cont_total == branch_cont_total
        steps = branch_cont_total
    elseif gen_cont_total < branch_cont_total
        gen_rate = 1.0
        branch_rate = branch_cont_total/gen_cont_total
        steps = gen_cont_total
    elseif gen_cont_total > branch_cont_total
        gen_rate = gen_cont_total/branch_cont_total
        branch_rate = 1.0 
        steps = branch_cont_total
    end

    #println(gen_cont_total)
    #println(branch_cont_total)
    #println(steps)

    #println(gen_rate)
    #println(branch_rate)
    #println("")

    cont_order = []
    gen_cont_start = 1
    branch_cont_start = 1
    for s in 1:steps
        gen_cont_end = min(gen_cont_total, trunc(Int,ceil(s*gen_rate)))
        #println(gen_cont_start:gen_cont_end)
        for j in gen_cont_start:gen_cont_end
            push!(cont_order, gen_cont_order[j])
        end
        gen_cont_start = gen_cont_end+1

        branch_cont_end = min(branch_cont_total, trunc(Int,ceil(s*branch_rate)))
        #println("$(s) - $(branch_cont_start:branch_cont_end)")
        for j in branch_cont_start:branch_cont_end
            push!(cont_order, branch_cont_order[j])
        end
        branch_cont_start = branch_cont_end+1
    end

    @assert(length(cont_order) == gen_cont_total + branch_cont_total)

    return cont_order
end

# note this is simialr to bus_gen_lookup in PowerModels
# core differences are taking network as an arg and filtering by gen_status
function gens_by_bus(network::Dict{String,<:Any})
    bus_gens = Dict(i => Any[] for (i,bus) in network["bus"])
    for (i,gen) in network["gen"]
        if gen["gen_status"] != 0
            push!(bus_gens["$(gen["gen_bus"])"], gen)
        end
    end
    return bus_gens
end


function deactivate_rate_a!(network::Dict{String,<:Any})
    network["active_rates"] = Int[]
    for (i,branch) in network["branch"]
        branch["rate_a_inactive"] = branch["rate_a"]
        delete!(branch, "rate_a")
    end
end

function activate_rate_a!(network::Dict{String,<:Any})
    if haskey(network, "active_rates")
        delete!(network, "active_rates")
    end

    for (i,branch) in network["branch"]
        if haskey(branch, "rate_a_inactive")
            branch["rate_a"] = branch["rate_a_inactive"]
            delete!(branch, "rate_a_inactive")
        end
    end
end

function activate_rate_a_violations!(network::Dict{String,<:Any})
    ac_flows = _PM.calc_branch_flow_ac(network)
    for (i,branch) in network["branch"]
        branch["pf_start"] = ac_flows["branch"][i]["pf"]
        branch["qf_start"] = ac_flows["branch"][i]["qf"]

        branch["pt_start"] = ac_flows["branch"][i]["pt"]
        branch["qt_start"] = ac_flows["branch"][i]["qt"]
    end

    line_flow_vio = false
    for (i,branch) in network["branch"]
        if !haskey(branch, "rate_a")
            if (ac_flows["branch"][i]["pf"]^2 + ac_flows["branch"][i]["qf"]^2 > branch["rate_a_inactive"]^2 ||
                ac_flows["branch"][i]["pt"]^2 + ac_flows["branch"][i]["qt"]^2 > branch["rate_a_inactive"]^2)
                info(_LOGGER, "add rate_a flow limit on branch $(i) $(branch["source_id"])")
                #branch["rate_a"] = branch["rate_a_inactive"] - max(abs(ac_flows["branch"][i]["qf"]), abs(ac_flows["branch"][i]["qt"]))
                branch["rate_a"] = branch["rate_a_inactive"]
                push!(network["active_rates"], branch["index"])
                line_flow_vio = true
            end
        else
            sm_fr = sqrt(ac_flows["branch"][i]["pf"]^2 + ac_flows["branch"][i]["qf"]^2)
            sm_to = sqrt(ac_flows["branch"][i]["pf"]^2 + ac_flows["branch"][i]["qf"]^2)
            vio = max(0.0, sm_fr - branch["rate_a"], sm_to - branch["rate_a"])
            if vio > 0.01
                warn(_LOGGER, "add rate_a flow limit violations $(vio) on branch $(i) $(branch["source_id"])")
            end
        end
    end

    return line_flow_vio
end

function update_active_power_data!(network::Dict{String,<:Any}, data::Dict{String,<:Any}; branch_flow=false)
    for (i,bus) in data["bus"]
        nw_bus = network["bus"][i]
        nw_bus["va"] = bus["va"]
    end

    for (i,gen) in data["gen"]
        nw_gen = network["gen"][i]
        nw_gen["pg"] = gen["pg"]
    end

    if branch_flow
        for (i,branch) in data["branch"]
            nw_branch = network["branch"][i]
            nw_branch["pf"] = branch["pf"]
            nw_branch["pt"] = branch["pt"]
        end
    end
end


function c1_extract_solution(network::Dict{String,<:Any}; branch_flow=false)
    sol = Dict{String,Any}()

    sol["bus"] = Dict{String,Any}()
    for (i,bus) in network["bus"]
        bus_dict = Dict{String,Any}()
        bus_dict["va"] = get(bus, "va", 0.0)
        bus_dict["vm"] = get(bus, "vm", 1.0)
        sol["bus"][i] = bus_dict
    end

    sol["shunt"] = Dict{String,Any}()
    for (i,shunt) in network["shunt"]
        shunt_dict = Dict{String,Any}()
        shunt_dict["gs"] = get(shunt, "gs", 0.0)
        shunt_dict["bs"] = get(shunt, "bs", 0.0)
        sol["shunt"][i] = shunt_dict
    end

    sol["gen"] = Dict{String,Any}()
    for (i,gen) in network["gen"]
        gen_dict = Dict{String,Any}()
        gen_dict["pg"] = get(gen, "pg", 0.0)
        gen_dict["qg"] = get(gen, "qg", 0.0)
        sol["gen"][i] = gen_dict
    end

    if branch_flow
        sol["branch"] = Dict{String,Any}()
        for (i,branch) in network["branch"]
            branch_dict = Dict{String,Any}()
            branch_dict["pf"] = get(branch, "pf", 0.0)
            branch_dict["qf"] = get(branch, "qf", 0.0)
            branch_dict["pt"] = get(branch, "pt", 0.0)
            branch_dict["qt"] = get(branch, "qt", 0.0)
            sol["branch"][i] = branch_dict
        end
    end

    return sol
end



##### Solution Analysis #####
function calc_c1_power_balance_deltas!(network::Dict{String,<:Any})
    flows = calc_c1_branch_flow_ac(network)
    _PM.update_data!(network, flows)

    balance = _PM.calc_power_balance(network)
    _PM.update_data!(network, balance)

    p_delta_abs = [abs(bus["p_delta"]) for (i,bus) in network["bus"] if bus["bus_type"] != 4]
    q_delta_abs = [abs(bus["q_delta"]) for (i,bus) in network["bus"] if bus["bus_type"] != 4]

    return (
        p_delta_abs_max = maximum(p_delta_abs),
        p_delta_abs_mean = mean(p_delta_abs),
        q_delta_abs_max = maximum(q_delta_abs),
        q_delta_abs_mean = mean(q_delta_abs),
    )
end



function calc_c1_violations(network::Dict{String,<:Any}, solution::Dict{String,<:Any}; vm_digits=3, rate_key="rate_c")
    vm_vio = 0.0
    for (i,bus) in network["bus"]
        if bus["bus_type"] != 4
            bus_sol = solution["bus"][i]

            # helps to account for minor errors in equality constraints
            sol_val = round(bus_sol["vm"], digits=vm_digits)

            #vio_flag = false
            if sol_val < bus["vmin"]
                vm_vio += bus["vmin"] - sol_val
                #vio_flag = true
            end
            if sol_val > bus["vmax"]
                vm_vio += sol_val - bus["vmax"]
                #vio_flag = true
            end
            #if vio_flag
            #    info(_LOGGER, "$(i): $(bus["vmin"]) - $(sol_val) - $(bus["vmax"])")
            #end
        end
    end

    pg_vio = 0.0
    qg_vio = 0.0
    for (i,gen) in network["gen"]
        if gen["gen_status"] != 0
            gen_sol = solution["gen"][i]

            if gen_sol["pg"] < gen["pmin"]
                pg_vio += gen["pmin"] - gen_sol["pg"]
            end
            if gen_sol["pg"] > gen["pmax"]
                pg_vio += gen_sol["pg"] - gen["pmax"]
            end

            if gen_sol["qg"] < gen["qmin"]
                qg_vio += gen["qmin"] - gen_sol["qg"]
            end
            if gen_sol["qg"] > gen["qmax"]
                qg_vio += gen_sol["qg"] - gen["qmax"]
            end
        end
    end


    sm_vio = NaN
    if haskey(solution, "branch")
        sm_vio = 0.0
        for (i,branch) in network["branch"]
            if branch["br_status"] != 0
                branch_sol = solution["branch"][i]

                s_fr = abs(branch_sol["pf"])
                s_to = abs(branch_sol["pt"])

                if !isnan(branch_sol["qf"]) && !isnan(branch_sol["qt"])
                    s_fr = sqrt(branch_sol["pf"]^2 + branch_sol["qf"]^2)
                    s_to = sqrt(branch_sol["pt"]^2 + branch_sol["qt"]^2)
                end

                # note true model is rate_c
                #vio_flag = false
                rating = branch[rate_key]

                if s_fr > rating
                    sm_vio += s_fr - rating
                    #vio_flag = true
                end
                if s_to > rating
                    sm_vio += s_to - rating
                    #vio_flag = true
                end
                #if vio_flag
                #    info(_LOGGER, "$(i), $(branch["f_bus"]), $(branch["t_bus"]): $(s_fr) / $(s_to) <= $(branch["rate_c"])")
                #end
            end
        end
    end

    return (vm=vm_vio, pg=pg_vio, qg=qg_vio, sm=sm_vio)
end


"returns a sorted list of branch flow violations"
function branch_c1_violations_sorted(network::Dict{String,<:Any}, solution::Dict{String,<:Any}; rate_key="rate_c")
    branch_violations = []

    if haskey(solution, "branch")
        for (i,branch) in network["branch"]
            if branch["br_status"] != 0
                branch_sol = solution["branch"][i]

                s_fr = abs(branch_sol["pf"])
                s_to = abs(branch_sol["pt"])

                if !isnan(branch_sol["qf"]) && !isnan(branch_sol["qt"])
                    s_fr = sqrt(branch_sol["pf"]^2 + branch_sol["qf"]^2)
                    s_to = sqrt(branch_sol["pt"]^2 + branch_sol["qt"]^2)
                end

                sm_vio = 0.0

                rating = branch[rate_key]
                if s_fr > rating
                    sm_vio = s_fr - rating
                end
                if s_to > rating && s_to - rating > sm_vio
                    sm_vio = s_to - rating
                end

                if sm_vio > 0.0
                    push!(branch_violations, (branch_id=branch["index"], sm_vio=sm_vio))
                end
            end
        end
    end

    sort!(branch_violations, by=(x) -> -x.sm_vio)

    return branch_violations
end
