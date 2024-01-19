#!/usr/bin/env julia
include("distributed.jl")
add_procs() #can be restored after package registration

# using Distributed
@everywhere include("/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/src/PowerModelsSecurityConstrained.jl")
@everywhere using .PowerModelsSecurityConstrained

@everywhere using JuMP
@everywhere using PowerModels
@everywhere using LinearAlgebra
@everywhere using DelimitedFiles
@everywhere using ArgParse

@everywhere using Memento
Memento.config!("debug")
@everywhere const LOGGER = Memento.getlogger(PowerModelsSecurityConstrained)

@everywhere using Ipopt
include("common.jl")
include("second-stage-soft-fp-with-stage1.jl")


case_dir = "/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/data/Network_1/"
ini_file = joinpath(case_dir, "inputfiles.ini")

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--start"
            help = "the starting index of the testing scenarios"
            arg_type = Int
        
        "--end"
            help = "the ending index of the testing scenarios"
            arg_type = Int

        "--result_dir"
            help = "the directory to the result"
        
        "--second_stage"
            help = "set to true if want to include the second stage"
            action = :store_true
    end

    return parse_args(s)
end


function main(args)
    result_dir = "solve_time_result/" * args["result_dir"]
    include_stage2 = args["second_stage"]
    start_idx = args["start"]
    end_idx = args["end"]

    for code in start_idx: end_idx
        scenario = "scenario_"*string(code)
        # TODO: change to string concatenation
        # time0 = time()
        # case = parse_c1_case(ini_file, scenario_id=scenario)
        # network = build_c1_pm_model(case)
        # nlp_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-6)
        # time1 = time()
        # # solve stage1
        # result = run_c1_opf_cheap_surrogate(network, ACPPowerModel, nlp_solver)
        # write_solve_time(result_dir, result, scenario)
        # update_data!(network, result["solution"])
        # correct_c1_solution!(network)
        # check_c1_network_solution(network)
        # write_c1_solution1(network, output_dir=joinpath(case_dir, scenario), solution_file="sol1_test_approx.txt")
        # solve stage2
        if include_stage2
            sol1_dir = "sol1_test_approx.txt"
            # sol1_dir = "solution1.txt"
            con = joinpath(case_dir, scenario, "case.con")
            inl = joinpath(case_dir, scenario, "case.inl")
            raw = joinpath(case_dir, scenario, "case.raw")
            rop = joinpath(case_dir, scenario, "case.rop")
            compute_c1_solution2(con, inl, raw, rop, 600000, 2, "network name"; output_dir=joinpath(case_dir, scenario), scenario_id=scenario, sol1_file=sol1_dir)
            # compute_c1_solution2(con, inl, raw, rop, 600000, 2, "network name"; scenario_id=scenario, sol1_file=sol1_dir)
        end
    end
end

main(parse_commandline())


#julia --project='~/xjx/SRIBD/PowerModelsSecurityConstrained.jl' test_all.jl --start 1 --end 10 --result_dir "result_hidden_8_l1_41_grad_41.txt" --second_stage