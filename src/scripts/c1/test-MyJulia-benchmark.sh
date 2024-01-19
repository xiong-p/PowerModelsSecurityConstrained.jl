#!/bin/sh

# network_dir='/home/jinxin/xjx/SRIBD/Network_1'
# for scenario in "$network_dir"/*/;
# do
#     echo $scenario
#     folder_name=$(basename "$scenario")
#     scenario_id="${folder_name%.*}"
#     # echo $scenario_id
#     InFile1=$scenario'case.con'
#     InFile2=$scenario'case.inl'
#     InFile3=$scenario'case.raw'
#     InFile4=$scenario'case.rop'
#     NetworkModel=$scenario_id

#     # if [ $scenario_id != "scenario_205" ]; then
#     #     continue
#     # fi

#     # cmd_one="julia --project='~/xjx/SRIBD/PowerModelsSecurityConstrained.jl' -e 'include(\"MyJulia1.jl\"); MyJulia1(\"${InFile1}\", \"${InFile2}\", \"${InFile3}\", \"${InFile4}\", 600, 2, \"${NetworkModel}\")'"
#     # echo $cmd_one
#     # eval $cmd_one&>MyJulia1.log

#     # cmd_two="julia --project='~/xjx/SRIBD/PowerModelsSecurityConstrained.jl' -e 'include(\"MyJulia2.jl\"); MyJulia2(\"${InFile1}\", \"${InFile2}\", \"${InFile3}\", \"${InFile4}\", 600, 2, \"${NetworkModel}\")'"
#     # echo $cmd_two
#     # eval $cmd_two&>MyJulia2.log
# done


# network_dir='/home/jxxiong/A-xjx/Network_03R-10/'
network_dir='/home/jxxiong/A-xjx/Network_1/'
# network_dir='/home/jxxiong/A-xjx/IEEE14/'
# for scenario in "$network_dir"/*/;
for scenario_id in $(seq 301 350);
do
    echo $scenario_id
    scenario=$network_dir"scenario_"$scenario_id"/"
    # cd $scenario || exit
    InFile1=$scenario'case.con'
    InFile2=$scenario'case.inl'
    InFile3=$scenario'case.raw'
    InFile4=$scenario'case.rop'
    NetworkModel="scenario_"$scenario_id
    echo $scenario

    cmd_one="julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' -e 'include(\"MyJulia1.jl\"); MyJulia1(\"${InFile1}\", \"${InFile2}\", \"${InFile3}\", \"${InFile4}\", 600, 2, \"${NetworkModel}\", \"${scenario}\")'"
    echo $cmd_one
    eval $cmd_one&>$scenario"MyJulia1.log"

    cmd_two="julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' -e 'include(\"MyJulia2.jl\"); MyJulia2(\"${InFile1}\", \"${InFile2}\", \"${InFile3}\", \"${InFile4}\", 600, 2, \"${NetworkModel}\", \"${scenario}\")'"
    echo $cmd_two
    eval $cmd_two&>$scenario"MyJulia2.log"
done