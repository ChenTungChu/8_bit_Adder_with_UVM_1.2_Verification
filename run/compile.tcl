if { [file exists work] } {
    vdel -all
}
vlib work
vmap work work

# ======================================================
#  Include directories
# ======================================================
set INC_DIRS "+incdir+../tb/pkg \
              +incdir+../tb/seq \
              +incdir+../tb/agent \
              +incdir+../tb/env \
              +incdir+../tb/test \
              +incdir+../tb/top \
              +incdir+../tb/ref_model \
              +incdir+../tb/scoreboard"


# ======================================================
#  Compile DUT
# ======================================================
vlog -sv ../dut/adder.sv


# ======================================================
#  Compile Testbench (UVM)
# ======================================================
vlog -sv -timescale 1ns/1ps +acc $INC_DIRS +define+UVM_NO_DPI ../tb/pkg/adder_pkg.sv
vlog -sv -timescale 1ns/1ps +acc $INC_DIRS ../tb/top/tb_top.sv
	
# ======================================================
#  Compile Testbench (UVM)
# ======================================================    
puts "\n==============================="
puts "Compilation Completed!"
puts "===============================\n"