// File: tb/test/adder_test.sv

`ifndef ADDER_TEST_SV
`define ADDER_TEST_SV

class adder_test extends base_test;

	`uvm_component_utils(adder_test)
	
	function new(string name = "adder_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ADDER_TEST", "Build phase started.", UVM_MEDIUM)
	endfunction
	
	task run_phase(uvm_phase phase);
		adder_seq seq;
        `uvm_info("ADDER_TEST", "Run phase started.", UVM_MEDIUM)

		phase.raise_objection(this);

		seq = adder_seq::type_id::create("seq");
        if (seq == null)
            `uvm_fatal("ADDER_TEST", "Failed to create adder_seq!")
        `uvm_info("ADDER_TEST", "Starting adder_seq on env.agent.seqr", UVM_LOW)
		seq.start(env.agent.seqr);

		phase.drop_objection(this);
        `uvm_info("ADDER_TEST", "Run phase completed.", UVM_MEDIUM)
	endtask
endclass

`endif