start_init = time()

include("distributed.jl")
add_procs() #can be restored after package registration

start_pkg = time()

#@everywhere using Pkg
#@everywhere Pkg.activate(".")

# @everywhere using PowerModelsSecurityConstrained
@everywhere include("/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/src/PowerModelsSecurityConstrained.jl")
@everywhere using .PowerModelsSecurityConstrained


include("approx_stage_1.jl")

println("package load time: $(time() - start_pkg)")

println("script startup time: $(time() - start_init)")


function Approx1(InFile1::String, InFile2::String, InFile3::String, InFile4::String, TimeLimitInSeconds::Int64, ScoringMethod::Int64, NetworkModel::String, output_dir::String, save_time_dir::String, result_dir::String)
    println("running MyJulia1")
    println("  $(InFile1)")
    println("  $(InFile2)")
    println("  $(InFile3)")
    println("  $(InFile4)")
    println("  $(TimeLimitInSeconds)")
    println("  $(ScoringMethod)")
    println("  $(NetworkModel)")

    approx_solution1(InFile1, InFile2, InFile3, InFile4, NetworkModel; output_dir=output_dir, save_time_dir=save_time_dir, result_dir=result_dir)
end