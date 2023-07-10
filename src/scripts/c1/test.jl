#!/usr/bin/env julia

include("/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained2.jl/src/PowerModelsSecurityConstrained2.jl")
using .PowerModelsSecurityConstrained2


using JuMP
using PowerModels

using Ipopt
case_dir = "/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained1.jl/test/data/c1/" #../test/data/c1/"

ini_file = joinpath(case_dir, "inputfiles.ini")    #"../test/data/c1/inputfiles.ini"

scenario = "scenario_02"

case = parse_c1_case(ini_file, scenario_id=scenario)

network = build_c1_pm_model(case)

# c1_solution = read_c1_solution1(network, output_dir=dirname(case.files["raw"]))
# update_data!(network, c1_solution)
# correct_c1_solution!(network)

# for (i,bus) in network["bus"]
#     # bus["vm"] = (bus["vmax"] + bus["vmin"])/2.0 + 0.04
#     bus["vm_start"] = min(bus["vm"] * 0.9, bus["vmax"])
#     bus["va_start"] = bus["va"]

#     bus["vr_start"] = bus["vm"]*cos(bus["va"]) 
#     bus["vi_start"] = bus["vm"]*sin(bus["va"])
# end
# for (i,gen) in network["gen"]
#     gen["qg_start"] = gen["qg"] * 0.5
#     gen["pg_start"] = gen["pg"] * 0.5
# end


# nlp_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-6)#, "mu_init"=>1e1)

# result = run_c1_opf_acp(network, nlp_solver)
# # result = run_c1_opf_cheap_target_acp(network, nlp_solver)
# # result = solve_ac_opf(network, nlp_solver)

# update_data!(network, result["solution"])
# correct_c1_solution!(network)
# check_c1_network_solution(network)

# write_c1_solution1(network, output_dir=joinpath(case_dir, scenario), solution_file="sol1_1.txt")


# for (i, r) in result["solution"]["bus"]
#     println(r["p_delta_abs"], r["q_delta_abs"])
# end


# for (i, b) in result["solution"]["branch"]
#     println(b["sm_slack"])
# end

# calc_c1_power_balance_deltas!(network)




#####################################
nlp_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-6)#, "mu_init"=>1e1)

result = run_c1_opf_acp(network, nlp_solver)