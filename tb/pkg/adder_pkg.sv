// File: tb/pkg/adder_pkg.sv

`ifndef ADDER_PKG_SV
`define ADDER_PKG_SV

package adder_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    // seq
    `include "../seq/adder_seq_item.sv"
    `include "../seq/adder_seq.sv"

    // ref
    `include "../ref_model/adder_ref_model_sv.sv"
    `include "../ref_model/adder_ref.sv"

    // scoreboard
    `include "../scoreboard/adder_scoreboard.sv"

    // agent
    `include "../agent/adder_driver.sv"
    `include "../agent/adder_monitor.sv"
    `include "../agent/adder_sequencer.sv"
    `include "../agent/adder_agent.sv"

    // env
    `include "../env/adder_env.sv"

    // test
    `include "../test/base_test.sv"
    `include "../test/adder_test.sv"
endpackage

`endif