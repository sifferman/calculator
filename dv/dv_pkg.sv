
`ifndef __DV_PKG_SV
`define __DV_PKG_SV

package dv_pkg;

    import calc_pkg::*;

    function automatic string num2string(num_t num);
        return $sformatf(
            "%s%s%0d.%0d%0d%0d%0d%0d%0d%0d x 10^%0d",
            num.error ? "E" : " ",
            num.sign ? "-" : " ",
            num.significand[7],
            num.significand[6],
            num.significand[5],
            num.significand[4],
            num.significand[3],
            num.significand[2],
            num.significand[1],
            num.significand[0],
            num.exponent
        );
    endfunction

    typedef struct packed {
        logic error;
        logic signed [$clog2(10**(NumDigits+1)):0] significand;
        logic unsigned [$clog2(NumDigits):0] exponent;
    } nobcd_num_t;

    function automatic nobcd_num_t num2nobcd(num_t num);
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
    function automatic num_t nobcd2num(nobcd_num_t nobcd);
        num_t num = '0;
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

    function automatic num_t num_add(num_t left, num_t right);
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


    function automatic real num2real(num_t num);
        real out;
        logic [4*NumDigits-1:0] significand = 0;
        for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
            significand += num.significand[i] * 10**i;
        end
        out = $itor(significand);
        out *= 10.0**(num.exponent);
        out *= 10.0**(-(calc_pkg::NumDigits-1));
        return out;
    endfunction

    function automatic real round_towards_zero(real r);
        integer log;
        integer scale;
        integer intermediate;
        real out;

        if (r == 0)
            return 0;
        if (r < 0)
            r *= -1;
        log = $rtoi($log10(r));
        scale = (log < 0) ? (calc_pkg::NumDigits-1) : (calc_pkg::NumDigits-1 - log);
        intermediate = $rtoi(r * 10**scale);
        out = $itor(intermediate);
        out *= 10.0**(-scale);
        return out;
    endfunction



endpackage

`endif
