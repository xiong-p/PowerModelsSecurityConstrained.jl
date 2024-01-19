start_init = time()

include("distributed.jl")
add_procs() #can be restored after package registration

start_pkg = time()

#@everywhere using Pkg
#@everywhere Pkg.activate(".")

# @everywhere using PowerModelsSecurityConstrained
@everywhere include("/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/src/PowerModelsSecurityConstrained.jl")
@everywhere using .PowerModelsSecurityConstrained


include("goc_c1_huristic.jl")

println("package load time: $(time() - start_pkg)")

println("script startup time: $(time() - start_init)")

""" get the benchmark result for stage1"""
function Benchmark1(InFile1::String, InFile2::String, InFile3::String, InFile4::String, TimeLimitInSeconds::Int64, ScoringMethod::Int64, NetworkModel::String, output_dir::String)
    println("running Benchmark1")
    println("  $(InFile1)")
    println("  $(InFile2)")
    println("  $(InFile3)")
    println("  $(InFile4)")
    println("  $(TimeLimitInSeconds)")
    println("  $(ScoringMethod)")
    println("  $(NetworkModel)")

    startup_time = 60
    save_time_dir = "benchmark_result/stage_one_solve_time_benchmark2.txt"
    compute_c1_solution1(InFile1, InFile2, InFile3, InFile4, TimeLimitInSeconds-startup_time, ScoringMethod, NetworkModel, save_time_dir=save_time_dir, output_dir=output_dir)
    # compute_c1_solution1(InFile1, InFile2, InFile3, InFile4, TimeLimitInSeconds-startup_time, ScoringMethod, NetworkModel, save_time_dir="benchmark_result/stage_one_solve_time_benchmark.txt", output_dir=output_dir)

end