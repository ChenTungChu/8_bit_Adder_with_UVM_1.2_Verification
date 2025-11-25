vsim -voptargs=+acc work.tb_top -uvmcontrol=all +UVM_VERBOSITY=UVM_HIGH

add wave -r sim:/tb_top/*

run -all

#quit -sim