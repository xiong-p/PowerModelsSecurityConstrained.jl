#!/usr/bin/env julia

include("/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained2.jl/src/PowerModelsSecurityConstrained2.jl")
using .PowerModelsSecurityConstrained2


using JuMP
using PowerModels

using Ipopt

function calc_feasible(network, factor, nlp_solver, idx, count)
    for (i,bus) in network["bus"]
        if parse(Int64, i) % idx != 0
            continue
        end
        bus["vm_fix"] = true
        bus["vm_start"] = max(min(bus["vm"]*factor, bus["vmax"]), bus["vmin"])
        bus["va_start"] = bus["va"]

        bus["vr_start"] = bus["vm"]*cos(bus["va"]) 
        bus["vi_start"] = bus["vm"]*sin(bus["va"])

        break
    end
    for (i,gen) in network["gen"]
        if parse(Int64, i) % idx != 0
            continue
        end
        gen["gen_fix"] = true
        gen["qg_start"] = max(min(gen["qg"]*factor, gen["qmax"]), gen["qmin"])
        gen["pg_start"] = max(min(gen["pg"]*factor, gen["pmax"]), gen["pmin"])
        
    end

    result = run_c1_opf_cheap_fix_acp(network, nlp_solver)
    update_data!(network, result["solution"])
    correct_c1_solution!(network)
    check_c1_network_solution(network)

    write_c1_solution1(network, output_dir=joinpath(case_dir, scenario, "sol1"), solution_file="sol1_$(idx)_$(count).txt")
    return result
end


# case_dir = "/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained2.jl/test/data/c1/"
case_dir = "/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained2.jl/test/data/Network_02O-173/"
ini_file = joinpath(case_dir, "inputfiles.ini")

scenario = "scenario_169"

case = parse_c1_case(ini_file, scenario_id=scenario)

network = build_c1_pm_model(case)
network1 = deepcopy(network)
nlp_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-8)#, "mu_init"=>1e1)

# c1_solution = read_c1_solution1(network, output_dir=dirname(case.files["raw"]))
# update_data!(network, c1_solution)
# correct_c1_solution!(network)



# result = calc_feasible(network, 1.05, nlp_solver, 13)

# result1 = calc_feasible(network1, 1.0, nlp_solver, 14)
for idx in 1:30
    for (i, fac) in enumerate(0.9:0.05:1.1)
        network1 = deepcopy(network)
        result = calc_feasible(network1, fac, nlp_solver, idx, i)
    end
end