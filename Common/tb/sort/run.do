#Exit current simulation

quit -sim

#Clear command line information

.main    clear

#Creating Libraries(Folder path),example : vlib ./

#基本不用改，除非你要改变库名称和路径

#vlib    ./lib/

#vlib    ./lib/work_a/

#vlib    ./lib/design/

#vlib    ./lib/altera_lib/

vlib     work

#map logic lib to folder path ,example:

#基本不用改，除非你要改变逻辑库名称

#vmap    base_space ./lib/work_a/        modelsim will creat a tab named base_space

#vmap    design    ./lib/design/

#vmap    altera_lib ./lib/altera_lib/    simulat the IP core will use

vmap    work    work

#Compile verilog Code ,exmaple : vlog -work [logic library's name] [the will Compiled file's path and name ]

#vlog    -work base_space    ./tb_mealy.v-----the tb file -->altera_lib file --> design file name-->ip core name(not_inst)

#这里要添加你的RTL文件、TB文件、IP核的.文件、IP核需要用到的库文件

vlog  -64  -work    work  +incdir+../../rtl -sv  -f ../../stl.f ./tb.sv -l compile.log

#Start-up simulation example :

#vsim    -t ns  -voptargs=+acc    -L [logic library1] -L [logic library2] ... [logic library of the tb file].[tb'sname]

#当你的TB文件的名字不是tb_module时，需要修改；

#当你需要添加其他优化选项时需要改

vsim  -64  -t ns  -voptargs=+acc    work.tb -l sim.log

#add wave and divider

#当你需要添加分割线时需要修改

#add    wave    -divider        {divider's name}

#add     wave      (-color red)    tb_xxx/*  |||||| #add     wave      (-color red)    tb's name/xxx_inst/signal

add        wave    tb/*

#run time

run 1ms 
