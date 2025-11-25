// File: tb/agent/adder_driver.sv

`ifndef ADDER_DRIVER_SV
`define ADDER_DRIVER_SV

class adder_driver extends uvm_driver #(adder_seq_item);
    virtual adder_if vif;

    `uvm_component_utils(adder_driver)

    function new(string name = "adder_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRIVER", "Virtual interface not set for driver!")
        end
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("DRIVER", "Driver started.", UVM_LOW)

        // Reset sequence
        vif.rst_n     <= 1'b0;
        vif.in_valid  <= 1'b0;
        vif.out_valid <= 1'b0;
        vif.a         <= '0;
        vif.b         <= '0;

        // wait 2 clk period to reset
        repeat (2) @(posedge vif.clk);

        // De-assert reset
        vif.rst_n    <= 1'b1;
        `uvm_info("DRIVER", "Reset deasserted.", UVM_LOW);

        @(posedge vif.clk);

        forever begin
            adder_seq_item req;
            seq_item_port.get_next_item(req);

            // Wait until DUT is ready to accept input
            @(posedge vif.clk iff vif.in_ready);
            vif.in_valid  <= 1'b1;
            vif.a         <= req.a;
            vif.b         <= req.b;

            @(posedge vif.clk);
            vif.in_valid <= 0;

            // Wait until DUT asserts out_valid (data ready)
            wait (vif.out_valid);
            @(posedge vif.clk iff vif.out_valid);
            vif.out_ready <= 1'b1;

            @(posedge vif.clk);
            vif.out_ready <= 1'b0;

            `uvm_info("DRIVER", $sformatf("Driver done: a = %0d, b = %0d, sum = %0d", req.a, req.b, req.sum), UVM_HIGH)
            seq_item_port.item_done();
        end
    endtask
endclass

`endif