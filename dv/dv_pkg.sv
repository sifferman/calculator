
`ifndef __DV_PKG_SV
`define __DV_PKG_SV

package dv_pkg;

    function automatic string num2string(calc_pkg::num_t num);
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

    function automatic real num2real(calc_pkg::num_t num);
        real out;
        logic [4*calc_pkg::NumDigits-1:0] significand = 0;
        for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
            significand += num.significand[i] * 10**i;
        end
        out = $itor(significand);
        out *= 10.0**(num.exponent);
        out *= 10.0**(-(calc_pkg::NumDigits-1));
        return out;
    endfunction

endpackage

`endif
