
module alu (
    input   logic           clk_i,
    input   logic           rst_i,

    input   calc_pkg::num_t left_i,
    input   calc_pkg::num_t right_i,
    input   calc_pkg::op_t  op_i,
    output  calc_pkg::num_t result_o
);

// STUB

function automatic calc_pkg::num_t add(calc_pkg::num_t left, calc_pkg::num_t right);
    automatic logic carry = 0;
    automatic logic prev_carry = 0;
    automatic calc_pkg::num_t sum = '0;

    for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
        {carry, sum.significand[i]} = left_i.significand[i] + right_i.significand[i] + 4'(prev_carry);
        if (carry) begin
            sum.significand[i] = left_i.significand[i] + right_i.significand[i] + 4'(prev_carry) - 4'd10;
            prev_carry = carry;
        end
    end
    return sum;
endfunction

function automatic calc_pkg::num_t sub(calc_pkg::num_t left, calc_pkg::num_t right);
    automatic logic borrow = 0;
    automatic logic prev_borrow = 0;
    automatic calc_pkg::num_t diff = '0;

    for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
        {borrow, diff.significand[i]} = left_i.significand[i] - right_i.significand[i] - 5'(prev_borrow);
        if (borrow) begin
            diff.significand[i] = left_i.significand[i] - right_i.significand[i] - 4'(prev_borrow) + 4'd10;
            prev_borrow = borrow;
        end
    end
    return diff;
endfunction

calc_pkg::num_t sum;
assign sum = add(left_i, right_i);
calc_pkg::num_t diff;
assign diff = sub(left_i, right_i);

always_comb begin
    result_o = 'x;
    case (op_i)
        calc_pkg::OP_NONE: ;
        calc_pkg::OP_ADD: result_o = sum;
        calc_pkg::OP_SUB: result_o = diff;
        default: $display("Unimplemented operation");
    endcase
end

endmodule
