// File: dut/adder.sv

//==========================================
// Handshake logic
//==========================================
// ...

module adder #(parameter WIDTH = 8)(
    input  logic             clk,
    input  logic             rst_n, 
    input  logic             in_valid,      // [Source] valid signal
    output logic             in_ready,      // [Adder]  ready signal
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic             out_valid,
    input  logic             out_ready,
    output logic [WIDTH-1:0] sum
);
    typedef enum logic [1:0] {IDLE, CALC, WAIT, DONE} state_t;
    
    state_t state, next_state;

//==========================================
// State definition
//==========================================
    always_comb begin
        // default value
        next_state = state;
        in_ready   = 1'b0;
        out_valid  = 1'b0;

        case (state)
            IDLE: begin
                in_ready = 1'b1;
                if (in_valid && in_ready)
                    next_state = CALC;
            end

            CALC: begin
                next_state = WAIT;
            end

            WAIT: begin
                out_valid = 1'b1;
                if (out_ready)
                    next_state = DONE; 
            end

            DONE: begin
                next_state = IDLE;
            end
        endcase
    end
    
//==========================================
// State transition
//==========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

//==========================================
// Assign output
//==========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sum <= '0;
        else if (state == CALC)
            sum <= a + b;
        else if (state == DONE)
            sum <= '0;
    end

endmodule