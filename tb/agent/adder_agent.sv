// File: tb/agent/adder_agent.sv

`ifndef ADDER_AGENT_SV
`define ADDER_AGENT_SV

class adder_agent extends uvm_agent;
    adder_driver    drv;
    adder_monitor   mon;
    adder_sequencer seqr;

    virtual adder_if vif;

    // Agent mode setting (active / passive)
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    `uvm_component_utils(adder_agent)

    // Constructor
    function new(string name = "adder_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AGENT", "Build phase started.", UVM_MEDIUM)

        // Get virtual interface from config_db
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "vif", vif))
            `uvm_fatal("AGENT", "Virtual interface not set for adder_agent!")

        // Read is_active from config_db, can set active/passive agent from test level
        void'(uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active));

        // Only active agent will create driver & sequencer
        if (is_active == UVM_ACTIVE) begin    
            drv  = adder_driver::type_id::create("drv", this);
            seqr = adder_sequencer::type_id::create("seqr", this);
        end
        mon  = adder_monitor::type_id::create("mon", this);
    endfunction

    // Connect phase
    function void connect_phase(uvm_phase phase);
        `uvm_info("AGENT", "Connect phase started.", UVM_MEDIUM)

        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
            drv.vif = vif;
        end
        mon.vif = vif;
    endfunction
endclass: adder_agent

`endif