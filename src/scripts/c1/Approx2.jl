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

include("second-stage-soft-fp-with-stage1.jl")

include("common.jl")


println("package load time: $(time() - start_pkg)")

println("script startup time: $(time() - start_init)")

case_dir ="/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/data/Network_1/"
function Approx2(con_file::String, inl_file::String, raw_file::String, rop_file::String, network_model::String, output_dir::String="", save_time_dir::String="")
    sol1_dir = "sol1_test_approx.txt"
    save_time_dir = "solve_time_result/"*save_time_dir
    compute_c1_solution2(con_file, inl_file, raw_file, rop_file, 600000, 2, "network name"; output_dir=output_dir, scenario_id=network_model, sol1_file=sol1_dir, solve_time_file=save_time_dir)
end
