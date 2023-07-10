start_init = time()

include("distributed.jl")
#add_procs() #can be restored after package registration

start_pkg = time()

#@everywhere using Pkg
#@everywhere Pkg.activate(".")
# include("/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained2.jl/src/PowerModelsSecurityConstrained2.jl")
# @everywhere using .PowerModelsSecurityConstrained2
@everywhere using PowerModelsSecurityConstrained

@everywhere using JuMP
@everywhere using Ipopt
@everywhere using PowerModels

@everywhere using Memento
@everywhere const LOGGER = Memento.getlogger(PowerModelsSecurityConstrained)

include("goc_c1_huristic.jl")
#include("second-stage-fp.jl")
include("second-stage-soft-fp.jl")
# include("second-stage-solution1.jl")


println("package load time: $(time() - start_pkg)")

println("script startup time: $(time() - start_init)")


# function MyJulia2(InFile1::String, InFile2::String, InFile3::String, InFile4::String, TimeLimitInSeconds::Int64, ScoringMethod::Int64, NetworkModel::String)
#     println("running MyJulia2")
#     println("  $(InFile1)")
#     println("  $(InFile2)")
#     println("  $(InFile3)")
#     println("  $(InFile4)")
#     println("  $(TimeLimitInSeconds)")
#     println("  $(ScoringMethod)")
#     println("  $(NetworkModel)")

#     compute_c1_solution2_fast(InFile1, InFile2, InFile3, InFile4, TimeLimitInSeconds, ScoringMethod, NetworkModel)

#     compute_c1_solution2(InFile1, InFile2, InFile3, InFile4, TimeLimitInSeconds, ScoringMethod, NetworkModel)
# end

function cal_stage2()
    case_dir = "/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained2.jl/test/data/Network_02O-173/"
    ini_file = joinpath(case_dir, "inputfiles.ini")

    # go through all scenarios under the network folder

    for scenario in sort!(readdir(joinpath(case_dir)), rev=true)[11:end]
        println(scenario)
        if !isdir(joinpath(case_dir, scenario))
            continue
        end
        
        con = joinpath(case_dir, scenario, "case.con")
        inl = joinpath(case_dir, scenario, "case.inl")
        raw = joinpath(case_dir, scenario, "case.raw")
        rop = joinpath(case_dir, scenario, "case.rop")

        # list all txt under the scenario folder that start with sol1_
        # sol1_files = filter(x -> occursin(r"^sol1_", x), readdir(joinpath(case_dir, scenario)))
        sol1_files = []
        for file in readdir(joinpath(case_dir, scenario, "sol1"))
            if occursin(r"^sol1_", file) & occursin(r".txt$", file)
                push!(sol1_files, file)
            end
        end
        sort!(sol1_files, rev=true)
        println(sol1_files)
        
        # for all feasible first-stage solutions, calculate the second-stage solutions under each contingency
        for sol1_file in sol1_files
            compute_c1_solution2(con, inl, raw, rop, 600000, 2, "network name"; output_dir=joinpath(case_dir, scenario), scenario_id=scenario, sol1_file=joinpath("sol1", sol1_file))
        end
        # compute_c1_solution2(con, inl, raw, rop, 600000, 2, "network name"; output_dir=joinpath(case_dir, scenario), scenario_id=scenario, sol1_file="sol1/sol1_1_1.txt")
    end
end

cal_stage2()