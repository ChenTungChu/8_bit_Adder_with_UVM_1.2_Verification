// File: tb/scoreboard/adder_scoreboard.sv

`ifndef ADDER_SCOREBOARD_SV
`define ADDER_SCOREBOARD_SV

// two analysis_imp, according to DUT and REF source
`uvm_analysis_imp_decl(_dut);
`uvm_analysis_imp_decl(_ref);

class adder_scoreboard extends uvm_component;

    // TLM ports: Receive data from DUT monitor and Reference model repectively
    uvm_analysis_imp_dut #(adder_seq_item, adder_scoreboard) dut_export;
    uvm_analysis_imp_ref #(adder_seq_item, adder_scoreboard) ref_export;

    // Internal storage: Reference model expected output queue
    adder_seq_item exp_q[$];
    int match_cnt = 0;      // transaction match counter

    `uvm_component_utils(adder_scoreboard)

    // Constructor
    function new(string name = "adder_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        dut_export = new("dut_export", this);
        ref_export = new("ref_export", this);
    endfunction

    // Write REF: Receive expected output from reference model
    function void write_ref(adder_seq_item req);
        if (req == null) begin
            `uvm_warning("SCOREBOARD", "Received null REF transaction; ignoring...");
            return;
        end

        exp_q.push_back(req);
        `uvm_info("SCOREBOARD", $sformatf("REF pushed: a = %0d, b = %0d, sum = %0d, exp_q size = %0d", req.a, req.b, req.sum, exp_q.size()), UVM_HIGH);
    endfunction

    // Write DUT: Receive actual DUT monitor output, compare it with REF
    function void write_dut(adder_seq_item item);
        adder_seq_item exp;

        if (item == null) begin
            `uvm_warning("SCOREBOARD", "Received null DUT transaction; ignoring...");
            return;
        end

        `uvm_info("SCOREBOARD", $sformatf("DUT got: a = %0d, b = %0d, sum = %0d", item.a, item.b, item.sum), UVM_HIGH);
    
        // Empty queue check
        if (exp_q.size() == 0 || exp_q[0] == null) begin
            `uvm_error("SCOREBOARD", "No reference transaction available!");
            return;
        end
        else begin
            exp = exp_q.pop_front();
        end

        if (item.sum !== exp.sum) begin
            `uvm_error("SCOREBOARD", $sformatf("Mismatch! DUT = %0d, REF = %0d, (a = %0d, b = %0d)", item.sum, exp.sum, item.a, item.b));
        end
        else begin
            match_cnt++;
            `uvm_info("SCOREBOARD", $sformatf("Match OK: a = %0d, b = %0d, sum = %0d; Total matches = %0d", item.a, item.b, item.sum, match_cnt), UVM_LOW);
        end
    endfunction
endclass

`endif