
module alu (
    input   logic           clk_i,
    input   logic           rst_i,

    input   calc_pkg::num_t left_i,
    input   calc_pkg::num_t right_i,
    input   calc_pkg::op_t  op_i,
    output  calc_pkg::num_t result_o
);

// STUB

logic carry;
logic prev_carry;
calc_pkg::num_t sum;
logic borrow;
logic prev_borrow;
calc_pkg::num_t diff;

always_comb begin
    carry = 0;
    prev_carry = 0;
    sum = '0;
    borrow = 0;
    prev_borrow = 0;
    diff = '0;

    result_o = 'x;
    case (op_i)
        calc_pkg::OP_NONE: ;
        calc_pkg::OP_ADD: begin
            for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
                {carry, sum.significand[i]} = left_i.significand[i] + right_i.significand[i] + 4'(prev_carry);
                if (carry) begin
                    sum.significand[i] = left_i.significand[i] + right_i.significand[i] + 4'(prev_carry) - 4'd10;
                    prev_carry = carry;
                end
            end
            result_o = sum;
        end
        calc_pkg::OP_SUB: begin
            for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
                {borrow, diff.significand[i]} = left_i.significand[i] - right_i.significand[i] - 5'(prev_borrow);
                if (borrow) begin
                    diff.significand[i] = left_i.significand[i] - right_i.significand[i] - 4'(prev_borrow) + 4'd10;
                    prev_borrow = borrow;
                end
            end
            result_o = diff;
        end
        default: ;
    endcase
end

endmodule
