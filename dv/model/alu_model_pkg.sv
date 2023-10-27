
`ifndef __ALU_MODEL_PKG_SV
`define __ALU_MODEL_PKG_SV

package alu_model_pkg;

    // Intermediate representation of calc_pkg::num_t
    typedef struct packed {
        logic error;
        logic signed [$clog2(10**(calc_pkg::NumDigits+1)):0] significand;
        logic unsigned [$clog2(calc_pkg::NumDigits):0] exponent;
    } nobcd_num_t;

    // Convert calc_pkg::num_t to alu_model_pkg::nobcd_num_t
    function automatic nobcd_num_t num2nobcd(calc_pkg::num_t num);
        nobcd_num_t nobcd = '0;
        nobcd_num_t temp = '0;
        for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
            temp.significand = num.significand[i];
            temp.significand *= 10**i;
            nobcd.significand += temp.significand;
        end
        if (num.sign) nobcd.significand *= -1;
        nobcd.exponent = num.exponent;
        nobcd.error = num.error;
        return nobcd;
    endfunction

    // Convert alu_model_pkg::nobcd_num_t to calc_pkg::num_t
    function automatic calc_pkg::num_t nobcd2num(nobcd_num_t nobcd);
        calc_pkg::num_t num = '0;
        if ($signed(nobcd.significand) < 0) begin
            nobcd.significand = -nobcd.significand;
            num.sign = 1;
        end
        num.exponent = nobcd.exponent;
        num.error = nobcd.error;
        for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
            num.significand[i] = (nobcd.significand%10);
            nobcd.significand /= 10;
        end
        return num;
    endfunction

    // Gold model for calc_pkg::num_t + calc_pkg::num_t
    function automatic calc_pkg::num_t num_add(calc_pkg::num_t left, calc_pkg::num_t right);
        nobcd_num_t left_nobcd = num2nobcd(left);
        nobcd_num_t right_nobcd = num2nobcd(right);
        nobcd_num_t out_nobcd = '0;
        while (left_nobcd.exponent != right_nobcd.exponent) begin
            if (left_nobcd.exponent < right_nobcd.exponent) begin
                left_nobcd.significand /= 10;
                left_nobcd.exponent++;
            end else begin
                right_nobcd.significand /= 10;
                right_nobcd.exponent++;
            end
        end
        if (left.sign) left_nobcd.significand *= 1;
        if (right.sign) right_nobcd.significand *= 1;
        out_nobcd.significand = left_nobcd.significand + right_nobcd.significand;
        out_nobcd.exponent = left_nobcd.exponent;
        while (`ABS(out_nobcd.significand) >= (10**(calc_pkg::NumDigits))) begin
            out_nobcd.significand /= 10;
            if (out_nobcd.exponent == 7)
                out_nobcd.error = 1;
            out_nobcd.exponent++;
        end
        while ((out_nobcd.exponent != 0) && (`ABS(out_nobcd.significand) < (10**(calc_pkg::NumDigits-1)))) begin
            out_nobcd.significand *= 10;
            out_nobcd.exponent--;
        end
        if (out_nobcd.error)
            out_nobcd.exponent = '0;
        return nobcd2num(out_nobcd);
    endfunction

endpackage

`endif
