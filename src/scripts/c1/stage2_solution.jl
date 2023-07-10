include("/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained2.jl/src/PowerModelsSecurityConstrained2.jl")
using .PowerModelsSecurityConstrained2
using Distributed
include("second-stage-soft-fp.jl")
case_dir = "/Users/xiongjinxin/A-xjx/SRIBD/PowerModelsSecurityConstrained2.jl/test/data/Network_02O-173/"
ini_file = joinpath(case_dir, "inputfiles.ini")
scenario = "scenario_169"
con = joinpath(case_dir, scenario, "case.con")
inl = joinpath(case_dir, scenario, "case.inl")
raw = joinpath(case_dir, scenario, "case.raw")
rop = joinpath(case_dir, scenario, "case.rop")
# compute_c1_solution2(con, files["inl"], files["raw"], files["rop"], trunc(Int, time_limit_total-time_sol1-60), scoring_method, "network name"; output_dir=output_dir, scenario_id=scenario_id)

compute_c1_solution2(con, inl, raw, rop, 600000, 2, "network name"; output_dir=joinpath(case_dir, scenario), scenario_id=scenario, sol1_file="sol1_1_1.txt")
