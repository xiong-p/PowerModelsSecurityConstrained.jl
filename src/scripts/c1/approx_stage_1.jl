#!/usr/bin/env julia
include("distributed.jl")
# add_procs() #can be restored after package registration

# using Distributed
# @everywhere include("/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/src/PowerModelsSecurityConstrained.jl")
# @everywhere using .PowerModelsSecurityConstrained

using JuMP
using PowerModels
using LinearAlgebra
using DelimitedFiles
using ArgParse

using Memento
const LOGGER = Memento.getlogger(PowerModelsSecurityConstrained)

using Ipopt
include("common.jl")


case_dir = "/home/jxxiong/A-xjx/Network_1/"
ini_file = joinpath(case_dir, "inputfiles.ini")

function approx_solution1(con_file::String, inl_file::String, raw_file::String, rop_file::String, network_model::String; output_dir::String="", save_time_dir::String="", result_dir::String="")
    result_dir = "solve_time_result/" * result_dir
    save_time_dir = "solve_time_result/" * save_time_dir
    scenario = network_model

    time0 = time()
    case = parse_c1_files(con_file, inl_file, raw_file, rop_file, scenario_id=network_model)
    network = build_c1_pm_model(case)
    nlp_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-3)
    time1 = time()

    result = run_c1_opf_cheap_surrogate(network, ACPPowerModel, nlp_solver)
    time2 = time()
    
    update_data!(network, result["solution"])
    correct_c1_solution!(network)
    check_c1_network_solution(network)
    write_c1_solution1(network, output_dir=output_dir, solution_file="sol1_test_approx.txt")
    time3 = time()
    write_solve_time(result_dir, result, scenario)
    write_solve_time(save_time_dir, scenario, 0.0, load_time=time1-time0, solve_time=time2-time1, filter_time=0.0, total_time = time3-time0)
end

#julia --project='~/xjx/SRIBD/PowerModelsSecurityConstrained.jl' test_all.jl --start 1 --end 10 --result_dir "result_hidden_8_l1_41_grad_41.txt" --second_stage