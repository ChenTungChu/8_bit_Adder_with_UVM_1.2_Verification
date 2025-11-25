// File: tb/test/base_test.sv

`ifndef ADDER_BASE_TEST_SV
`define ADDER_BASE_TEST_SV

class base_test extends uvm_test;
    adder_env env;

    `uvm_component_utils(base_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("BASE_TEST", "Build phase started.", UVM_MEDIUM);
    
        env = adder_env::type_id::create("env", this);
        if (env == null)
            `uvm_fatal("BASE_TEST", "Failed to create adder_env!");
        
        // Future extension: Can pass config to lower env
        // uvm_config_db#(int)::set(this, "env.agent.*, "num_transactions", 20);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("BASE_TEST", "Base test run phase (no operation).", UVM_MEDIUM);
    endtask
endclass

`endif