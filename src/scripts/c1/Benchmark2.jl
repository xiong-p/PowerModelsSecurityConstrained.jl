start_init = time()

include("distributed.jl")
add_procs() #can be restored after package registration

start_pkg = time()

#@everywhere using Pkg
#@everywhere Pkg.activate(".")

# @everywhere using PowerModelsSecurityConstrained
@everywhere include("/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/src/PowerModelsSecurityConstrained.jl")
@everywhere using .PowerModelsSecurityConstrained

@everywhere using JuMP
@everywhere using Ipopt
@everywhere using PowerModels

@everywhere using Memento
@everywhere const LOGGER = Memento.getlogger(PowerModelsSecurityConstrained)

include("goc_c1_huristic.jl")
include("second-stage-soft-fp.jl")


println("package load time: $(time() - start_pkg)")

println("script startup time: $(time() - start_init)")

""" get stage2 solution for benchmark"""
function Benchmark2(InFile1::String, InFile2::String, InFile3::String, InFile4::String, TimeLimitInSeconds::Int64, ScoringMethod::Int64, NetworkModel::String, output_dir::String)
    println("running Benchmark2")
    println("  $(InFile1)")
    println("  $(InFile2)")
    println("  $(InFile3)")
    println("  $(InFile4)")
    println("  $(TimeLimitInSeconds)")
    println("  $(ScoringMethod)")
    println("  $(NetworkModel)")
    

    # compute_c1_solution2_fast(InFile1, InFile2, InFile3, InFile4, TimeLimitInSeconds, ScoringMethod, NetworkModel)

    compute_c1_solution2(InFile1, InFile2, InFile3, InFile4, TimeLimitInSeconds, ScoringMethod, NetworkModel, output_dir=output_dir)
end
