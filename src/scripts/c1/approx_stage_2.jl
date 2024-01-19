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


case_dir = "/home/jxxiong/A-xjx/Network_1/"
ini_file = joinpath(case_dir, "inputfiles.ini")

function approx_solution2(con_file::String, inl_file::String, raw_file::String, rop_file::String, network_model::String; output_dir::String="", save_time_dir="")
    sol1_dir = "sol1_test_approx.txt"
    compute_c1_solution2(con_file, inl_file, raw_file, rop_file, 600000, 2, "network name"; output_dir=output_dir, scenario_id=network_model, sol1_file=sol1_dir, solve_time_file=save_time_dir)
end