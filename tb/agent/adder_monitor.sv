// File: tb/agent/adder_monitor.sv

`ifndef ADDER_MONITOR_SV
`define ADDER_MONITOR_SV

class adder_monitor extends uvm_component;
    virtual adder_if vif;
    uvm_analysis_port #(adder_seq_item) ap;

    `uvm_component_utils(adder_monitor)

    function new(string name = "adder_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MONITOR", "Virtual interface not set for monitor!");
        end
    endfunction

    task run_phase(uvm_phase phase);
        adder_seq_item item;
        `uvm_info("MONITOR", "Monitor started.", UVM_LOW);

        forever begin
            @(posedge vif.clk);
            #1step;

            if (!vif.rst_n) begin
                `uvm_info("MONITOR", "RESET asserted.", UVM_LOW);
                continue;
            end

            if (vif.out_valid && vif.out_ready) begin
                item = adder_seq_item::type_id::create("item", this);

                item.a   = vif.a;
                item.b   = vif.b;
                item.sum = vif.sum;

                `uvm_info("MONITOR", $sformatf(" Handshake captured: a = %0d, b = %0d, sum = %0d", item.a, item.b, item.sum), UVM_HIGH);
                ap.write(item); 
            end
        end
    endtask
endclass

`endif