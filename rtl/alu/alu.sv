
module alu (
    input   logic           clk_i,
    input   logic           rst_i,

    input   calc_pkg::num_t left_i,
    input   calc_pkg::num_t right_i,
    input   calc_pkg::op_t  op_i,
    output  logic           in_ready_o,
    input   logic           in_valid_i,

    output  calc_pkg::num_t result_o,
    input   logic           out_ready_i,
    output  logic           out_valid_o
);

generate
if (USE_ALU_MODEL) begin : model

assign in_ready_o = 1;
assign out_valid_o = 1;

`ifndef SYNTHESIS
always_comb begin
    result_o = '0;
    case (op_i)
        calc_pkg::OP_NONE: ;
        calc_pkg::OP_ADD: result_o = alu_model_pkg::num_add(left_i, right_i);
        calc_pkg::OP_SUB: result_o = alu_model_pkg::num_sub(left_i, right_i);
        default: ;
    endcase
end
`endif

end else begin : nomodel

// handle sign change
calc_pkg::num_t signed_right;
always_comb begin
    if (op_i == calc_pkg::OP_SUB)
        signed_right = calc_pkg::neg(right_i);
    else
        signed_right = right_i;
end

// state machine and valid/ready
typedef enum logic {
    S_IDLE,
    S_BUSY
} state_t;

state_t state_d, state_q;

logic           add_in_ready;
logic           add_in_valid;
calc_pkg::num_t add_result;
logic           add_out_valid;

// logic           mult_in_ready;
// logic           mult_in_valid;
// calc_pkg::num_t mult_result;
// logic           mult_out_valid;

// logic           div_in_ready;
// logic           div_in_valid;
// calc_pkg::num_t div_result;
// logic           div_out_valid;

assign in_ready_o = add_in_ready;
// assign in_ready_o = add_in_ready && mult_in_ready && div_in_ready;
assign out_valid_o = add_out_valid;
// assign out_valid_o = add_out_valid || mult_out_valid || div_out_valid;

always_comb begin
    add_in_valid = 0;
    mult_in_valid = 0;
    div_in_valid = 0;
    state_d = state_q;
    case (state_q)
        S_IDLE: begin
            if (in_valid_i) begin
                case (op_i)
                    calc_pkg::OP_NONE: ;
                    calc_pkg::OP_ADD: add_in_valid = 1;
                    calc_pkg::OP_SUB: add_in_valid = 1;
                    // calc_pkg::OP_MUL: mult_in_valid = 1;
                    // calc_pkg::OP_DIV: div_in_valid = 1;
                    default: ;
                endcase
                state_d = S_BUSY;
            end
        end
        S_BUSY: begin
            if (out_valid_o)
                state_d = S_IDLE;
        end
    endcase
end

assign result_o = add_result;
// assign result_o = add_result | mult_result | div_result;

// modules
alu_add alu_add (
    .clk_i,
    .rst_i,

    .left_i,
    .right_i(signed_right),
    .in_ready_o(add_in_ready),
    .in_valid_i(add_in_valid),

    .result_o(add_result),
    .out_ready_i(out_ready_i),
    .out_valid_o(add_out_valid)
);

// assign mult_in_ready = 1;
// assign mult_result = '{default:'0, error:1};
// assign mult_out_valid = 0;

// assign div_in_ready = 1;
// assign div_result = '{default:'0, error:1};
// assign div_out_valid = 0;

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state_q <= S_IDLE;
    end else begin
        state_q <= state_d;
    end
end

end
endgenerate

endmodule
