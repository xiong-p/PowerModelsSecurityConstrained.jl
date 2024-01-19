#!/usr/bin/env julia
using ArgParse
@everywhere using PowerModelsSecurityConstrained

@everywhere include("goc_c1_huristic.jl")

function scopf_main2(args)
    network_dir = "/home/jxxiong/A-xjx/Network_1/"
    scenario = args["scenario"]
    scenario_dir = joinpath(network_dir, scenario)

    InFile1=joinpath(scenario_dir, "case.con")
    InFile2=joinpath(scenario_dir, "case.inl")
    InFile3=joinpath(scenario_dir, "case.raw")
    InFile4=joinpath(scenario_dir, "case.rop")

    TimeLimitInSeconds=6000
    ScoringMethod=2
    NetworkModel=scenario
    output_dir = scenario_dir
    skip_solution2 = false

    time_sol1_start = time()
    compute_c1_solution1(InFile1, InFile2, InFile3, InFile4, TimeLimitInSeconds, ScoringMethod, NetworkModel; output_dir=output_dir)
    time_sol1 = time() - time_sol1_start

    if !skip_solution2
        compute_c1_solution2(InFile1, InFile2, InFile3, InFile4, trunc(Int, TimeLimitInSeconds-time_sol1-60), ScoringMethod, NetworkModel; output_dir=output_dir)
    end
end

function parse_scopf_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--file", "-f"
            help = "the data initiation file (.ini)"
            required = true
        "--scenario", "-s"
            help = "the scenario to run (directory)"
            default = ""
        "--scoring-method", "-m"
            help = "the objective function (1,2,3,4)"
            arg_type = Int
            default = 2
        "--time-limit", "-t"
            help = "solution 1 runtime limit (seconds)"
            arg_type = Int
            default = 600000 #2700
        "--hard-time-limit"
            help = "solution 1 and 2 runtime limit (seconds)"
            arg_type = Int
            default = 600000 #34200
        "--distribute", "-d"
            help = "run on multiple processes"
            action = :store_true
        "--skip-solution2"
            help = "skip computation of solution2 file"
            action = :store_true
        "--remove-solutions"
            help = "delete the solution files after competition"
            action = :store_true
        "--gurobi", "-g"
            help = "use Gurobi for solving lp, qp and mip problems"
            action = :store_true
            #default = false
    end

    return parse_args(s)
end


# scopf_main(parse_scopf_commandline())
# cal_stage2("scenario_15", "solution1.txt")
scopf_main2(parse_scopf_commandline())

# julia --project='~/xjx/SRIBD/PowerModelsSecurityConstrained.jl' compute_stage1_benchmark.jl --scenario "scenario_201" --file "inputfiles.ini"