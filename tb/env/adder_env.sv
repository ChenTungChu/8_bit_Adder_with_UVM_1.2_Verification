// File: tb/env/adder_env.sv

`ifndef ADDER_ENV_SV
`define ADDER_ENV_SV

class adder_env extends uvm_env;
    adder_agent      agent;
    adder_ref        refm;
    adder_scoreboard scb;

    `uvm_component_utils(adder_env)

    // Constructor
    function new(string name = "adder_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ENV", "Build phase started.", UVM_LOW)

        agent = adder_agent::type_id::create("agent", this);
        refm  = adder_ref::type_id::create("refm", this);
        scb   = adder_scoreboard::type_id::create("scb", this);

        if (agent == null || refm == null || scb == null)
            `uvm_fatal("ENV", "Failed to create one or more components!")
        else
            `uvm_info("ENV", "All components successfully created", UVM_LOW)
    endfunction

    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("ENV", "Connect phase started.", UVM_LOW)

        agent.mon.ap.connect(refm.in_imp);      // DUT monitor -> ref model
        agent.mon.ap.connect(scb.dut_export);   // DUT monitor -> scoreboard
        refm.out_port.connect(scb.ref_export);  // Ref model -> scoreboard
    endfunction
endclass

`endif