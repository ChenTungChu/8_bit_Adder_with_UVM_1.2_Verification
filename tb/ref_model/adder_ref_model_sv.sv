// File: tb/ref_model/adder_ref_model_sv.sv

`ifndef ADDER_REF_MODEL_SV_SV
`define ADDER_REF_MODEL_SV_SV

function int adder_ref_model_sv(input int a, input int b);
    adder_ref_model_sv = a + b;
endfunction

`endif