// File: tb/seq/adder_seq_item.sv

`ifndef ADDER_SEQ_ITEM_SV
`define ADDER_SEQ_ITEM_SV

class adder_seq_item extends uvm_sequence_item;

    `uvm_object_utils(adder_seq_item)       // Factory registration

    randc bit [7:0] a;
    randc bit [7:0] b;
    bit       [7:0] sum;

    constraint no_overflow_c {
        (a + b) inside {[0:255]};
    }

    function new(string name = "adder_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("a = %0d, b = %0d", a, b);
    endfunction

    // Many big companies will require compare() on every seq_item
    function bit compare(adder_seq_item rhs, output string diff);
        diff = "";
        if (this.sum !== rhs.sum) begin
            diff = $sformatf("Sum mismatch! Expected: %0d, Got: %0d", rhs.sum, this.sum);
            return 0;
        end
        return 1;
    endfunction
endclass

`endif