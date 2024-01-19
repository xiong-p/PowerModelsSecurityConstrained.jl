#!/bin/bash

#cmd_warmup="julia warmup.jl"
#eval $cmd_warmup&>warmup.log

export InFile1="../../../test/data/c1/scenario_02/case.con"
export InFile2="../../../test/data/c1/scenario_02/case.inl"
export InFile3="../../../test/data/c1/scenario_02/case.raw"
export InFile4="../../../test/data/c1/scenario_02/case.rop"
export NetworkModel="IEEE 14"

cmd_one="julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' -e 'include(\"MyJulia1.jl\"); MyJulia1(\"${InFile1}\", \"${InFile2}\", \"${InFile3}\", \"${InFile4}\", 600, 2, \"${NetworkModel}\", \"""\")'"
echo $cmd_one
eval $cmd_one&>MyJulia1.log

cmd_two="julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' -e 'include(\"MyJulia2.jl\"); MyJulia2(\"${InFile1}\", \"${InFile2}\", \"${InFile3}\", \"${InFile4}\", 600, 2, \"${NetworkModel}\", \"""\")'"
echo $cmd_two
eval $cmd_two&>MyJulia2.log
