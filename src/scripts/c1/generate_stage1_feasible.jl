#!/usr/bin/env julia
include("distributed.jl")
# add_procs() #can be restored after package registration

@everywhere include("/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/src/PowerModelsSecurityConstrained.jl")
@everywhere using .PowerModelsSecurityConstrained

@everywhere using JuMP
@everywhere using PowerModels

@everywhere using Ipopt
@everywhere using ArgParse
@everywhere using Random
@everywhere using Distributed

@everywhere using Memento
@everywhere const LOGGER = Memento.getlogger(PowerModelsSecurityConstrained)

include("second-stage-soft-fp-with-stage1.jl")

include("common.jl")
include("../../io/goc_c1.jl")


function calc_first_stage_feasible(network, factor, nlp_solver, idx, count, case_dir, scenario, sample_fac)
    # for each idx, fix idx number of buses and generators by uniformly sampling, 
    # each sample 5 times, with factor ranging from 0.9 to 1.1 with step size 0.05

    num_bus = length(network["bus"])
    num_gen = length(network["gen"])
    println("num_bus: ", num_bus)
    println("num_gen: ", num_gen)
    # uniformly sample idx number from 1 to num_bus
    bus_idx = randperm(num_bus)[1:trunc(Int, num_bus*sample_fac)]
    gen_idx = randperm(num_gen)[1:trunc(Int, num_gen*sample_fac)]

    for (i,bus) in network["bus"]
        if !(parse(Int64, i) in bus_idx)
            continue
        end

        bus["vm_fix"] = true
        bus["vm_start"] = max(min(bus["vm"]*factor, bus["vmax"]), bus["vmin"])
        bus["va_start"] = bus["va"]

        bus["vr_start"] = bus["vm"]*cos(bus["va"]) 
        bus["vi_start"] = bus["vm"]*sin(bus["va"])
    end

    for (i,gen) in network["gen"]
        if !(parse(Int64, i) in gen_idx)
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

function cal_stage2(scenario, sol1_file, case_dir)
    ini_file = joinpath(case_dir, "inputfiles.ini")
    con = joinpath(case_dir, scenario, "case.con")
    inl = joinpath(case_dir, scenario, "case.inl")
    raw = joinpath(case_dir, scenario, "case.raw")
    rop = joinpath(case_dir, scenario, "case.rop")

    compute_c1_solution2(con, inl, raw, rop, 600000, 2, "model 1"; output_dir=joinpath(case_dir, scenario), scenario_id=scenario, sol1_file=sol1_file)
end

"""generate stage1 feasible solution based on one benchmark solution by 
fixing some buses and generators""
"""
function main(args)
    println("scenario: ", args["scenario"])
    scenario = args["scenario"]
    case_dir = "/home/jxxiong/A-xjx/Network_1/"
    # case_dir = "/home/jxxiong/A-xjx/Network_03R-10/"
    ini_file = joinpath(case_dir, "inputfiles.ini")

    case = parse_c1_case(ini_file, scenario_id=scenario)

    network = build_c1_pm_model(case)
    nlp_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-8)

    c1_solution = read_c1_solution1(network, output_dir=dirname(case.files["raw"]))
    update_data!(network, c1_solution)
    correct_c1_solution!(network)

    for idx in 1:10
        for (i, fac) in enumerate(rand(0.8:1.2, 5))
            network1 = deepcopy(network)
            result = calc_first_stage_feasible(network1, fac, nlp_solver, idx, i, case_dir, scenario, 0.08)
            cal_stage2(scenario, "sol1/sol1_$(idx)_$(i)" * ".txt", case_dir)
        end
    end

    # for idx in 9:10
    #     for (i, fac) in enumerate(rand(0.8:0.1:1.2, 5))
    #         network1 = deepcopy(network)
    #         result = calc_first_stage_feasible(network1, fac, nlp_solver, idx, i, case_dir, scenario, 0.1)
    #         cal_stage2(scenario, "sol1/sol1_$(idx)_$(i)" * ".txt", case_dir)
    #     end
    # end
end


function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--scenario", "-s"
            help = "the scenario to run (directory)"
            default = "scenario_1"
    end

    return parse_args(s)
end


main(parse_commandline())

#julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' generate_stage1_feasible.jl --scenario "scenario_508"