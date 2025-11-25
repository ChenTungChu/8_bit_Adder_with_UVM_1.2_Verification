// File: tb/ref_model/adder_ref.sv

`ifndef ADDER_REF_MODEL_SV
`define ADDER_REF_MODEL_SV

// Import UVM in case package does not get compiled first
import uvm_pkg::*;
`include "uvm_macros.svh"

// Call DPI
//import "DPI-C" function int adder_ref_model_cpp(input int a, input int b);
//import "DPI-C" function int adder_ref_model_py(input int a, input int b);

class adder_ref extends uvm_component;

	// Receive DUT monitor exported transaction
	uvm_analysis_imp #(adder_seq_item, adder_ref) in_imp;
	
	// Output transaction from golden mode to scoreboard 
	uvm_analysis_port #(adder_seq_item) out_port;
	
	`uvm_component_utils(adder_ref)
	
	function new(string name = "adder_ref", uvm_component parent = null);
		super.new(name, parent);
		in_imp    = new("in_imp", this);
		out_port  = new("out_port", this);
	endfunction
	
	// Receive transaction from monitor and call C++ golden model
	function void write(adder_seq_item item);
		adder_seq_item golden = adder_seq_item::type_id::create("golden");
		int result;
		
		// Copy input fields
		golden.a = item.a;
		golden.b = item.b;
		
		// Call SV or C++ (DPI-C) or Call Python
        result = adder_ref_model_sv(item.a, item.b);
		//result = adder_ref_model_cpp(item.a, item.b);
		//result = adder_ref_model_py(item.a, item.b);
		
		golden.sum = result;  // Correct answer
		
		`uvm_info("REF_MODEL", $sformatf("REF_MODEL: a = %0d, b = %0d, sum = %0d", golden.a, golden.b, golden.sum), UVM_HIGH)
		
		// Broadcast the correct answer to scoreboard
		out_port.write(golden); 
    endfunction
endclass

`endif