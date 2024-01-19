for scenario_id in $(seq 1 150);
do 
    network_dir='/home/jxxiong/A-xjx/Network_03R-10/'
    scenario=$network_dir"scenario_"$scenario_id"/"
    # cd $scenario || exit
    InFile1=$scenario'case.con'
    InFile2=$scenario'case.inl'
    InFile3=$scenario'case.raw'
    InFile4=$scenario'case.rop'
    NetworkModel="scenario_"$scenario_id
    echo $scenario

    cmd_one="julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' -e 'include(\"Benchmark1.jl\"); Benchmark1(\"${InFile1}\", \"${InFile2}\", \"${InFile3}\", \"${InFile4}\", 600, 2, \"${NetworkModel}\", \"${scenario}\")'"
    echo $cmd_one
    eval $cmd_one&>$scenario"Benchmark1.log"

    cmd_two="julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' -e 'include(\"Benchmark2.jl\"); Benchmark2(\"${InFile1}\", \"${InFile2}\", \"${InFile3}\", \"${InFile4}\", 600, 2, \"${NetworkModel}\", \"${scenario}\")'"
    echo $cmd_two
    eval $cmd_two&>$scenario"Benchmark2.log"

    scenario="scenario_"$scenario_id
    cmd_three="julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' generate_stage1_feasible.jl --scenario ${scenario}"
    eval $cmd_three
done