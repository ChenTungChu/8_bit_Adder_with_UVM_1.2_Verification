// File: tb/top/tb_top.sv

`timescale 1ns/1ps

// Declare interface
interface adder_if(input logic clk);
    logic       rst_n;
    logic       in_valid;
    logic       in_ready;
    logic [7:0] a;
    logic [7:0] b;
    logic       out_valid;
    logic       out_ready;
    logic [7:0] sum;
endinterface: adder_if


// DUT Wrapper + UVM Connection
module tb_top;

    // Clock generation
    logic clk;
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end


    // Instantiate interface
    adder_if adder_vif(clk);

    // Instantiate DUT
    adder dut(.clk      (clk),
              .rst_n    (adder_vif.rst_n),
              .in_valid (adder_vif.in_valid),
              .in_ready (adder_vif.in_ready),
              .a        (adder_vif.a),
              .b        (adder_vif.b),
              .out_valid(adder_vif.out_valid),
              .out_ready(adder_vif.out_ready),
              .sum      (adder_vif.sum)
    );

    // UVM setup
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import adder_pkg::*;


    initial begin
        // Open waveform
        $dumpfile("adder_wave.vcd");
        $dumpvars(0, tb_top);
        $dumpvars(0, adder_vif);

        // Import virtual interface into UVM environment
        uvm_config_db#(virtual adder_if)::set(null, "*", "vif", adder_vif);

        // Execute UVM verification
        run_test("adder_test");
    end
endmodule: tb_top