// File: tb/seq/adder_seq.sv

`ifndef ADDER_SEQ_SV
`define ADDER_SEQ_SV

class adder_seq extends uvm_sequence #(adder_seq_item);
    `uvm_object_utils(adder_seq)

    int num_transactions    = 5;
    int transaction_counter = 1;

    function new(string name = "adder_seq");
        super.new(name);
    endfunction

    task body();
        if (starting_phase != null)
            starting_phase.raise_objection(this, "adder_seq started");

        repeat (num_transactions) begin
            adder_seq_item req = adder_seq_item::type_id::create("req");
            `uvm_info("SEQ", $sformatf("Start transaction # %0d", transaction_counter), UVM_MEDIUM);
            start_item(req);
            if (!req.randomize()) begin
                `uvm_error("SEQ", "Randomization failed for adder_seq_item")
            end
            assert(req.randomize());
            `uvm_info("SEQ", $sformatf("Generated: %s", req.convert2string()), UVM_MEDIUM);
            finish_item(req);
            transaction_counter++;
        end

        if (starting_phase != null)
            starting_phase.drop_objection(this, "adder_seq completed");
    endtask
endclass

`endif