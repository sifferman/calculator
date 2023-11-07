
`ifndef __DV_PKG_SV
`define __DV_PKG_SV

package dv_pkg;
    `ifndef SYNTHESIS

    function automatic string num2string(calc_pkg::num_t num);
        string out = $sformatf(
            "%s%s%0d.",
            num.error ? "E" : " ",
            num.sign ? "-" : " ",
            num.significand[calc_pkg::NumDigits-1]
        );
        for (integer i = 0; i < calc_pkg::NumDigits-1; i++) begin
            out = {out, $sformatf("%0d", num.significand[calc_pkg::NumDigits-2-i])};
        end
        out = {out, $sformatf(" x 10^%0d", num.exponent)};
        return out;
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
        if (num.sign) out *= -1;
        return out;
    endfunction

    function automatic calc_pkg::num_t random_num();
        calc_pkg::num_t num;
        integer random;
        num.sign = $urandom_range(0,1);
        num.error = 0;
        random = $urandom_range(0,3);
        unique case (random)
            0: num.exponent = 0;
            1: num.exponent = 0;
            2: num.exponent = $urandom_range(1,6);
            3: num.exponent = 7;
        endcase
        for (integer j = 0; j < calc_pkg::NumDigits; j++) begin
            random = $urandom_range(0,1);
            unique case (random)
                0: num.significand[j] = 0;
                1: num.significand[j] = $urandom_range(1, 9);
            endcase
        end
        if (num.exponent != 0)
            num.significand[calc_pkg::NumDigits-1] = $urandom_range(1, 9);
        if (num.significand == '0)
            num.exponent = 0;
        return num;
    endfunction

    function automatic void print_segments(logic [calc_pkg::NumDigits-1:0][7:0] segments);
        string row1 = "";
        string row2 = "";
        string row3 = "";
        string row4 = "";
        string row5 = "";
        integer i = 0;
        integer s;
        for (i = 0; i < calc_pkg::NumDigits; i++) begin
            s = calc_pkg::NumDigits-1-i;
            row1 = {row1, $sformatf(" %s    ",  (segments[s][6] ? "-" : " "))};
            row2 = {row2, $sformatf("%s %s   ", (segments[s][1] ? "|" : " "), (segments[s][5] ? "|" : " "))};
            row3 = {row3, $sformatf(" %s    ",  (segments[s][0] ? "-" : " "))};
            row4 = {row4, $sformatf("%s %s   ", (segments[s][2] ? "|" : " "), (segments[s][4] ? "|" : " "))};
            row5 = {row5, $sformatf(" %s  %s ", (segments[s][3] ? "-" : " "), (segments[s][7] ? "." : " "))};
        end
        row1 = {row1, "\n"};
        row2 = {row2, "\n"};
        row3 = {row3, "\n"};
        row4 = {row4, "\n"};
        row5 = {row5, "\n"};
        $display(row1, row2, row3, row4, row5);
    endfunction

    function automatic calc_pkg::buttons_t button2buttons(calc_pkg::active_button_t active_button);
        unique case (active_button)
            calc_pkg::B_ON:         return '{on:1, default:0};
            calc_pkg::B_OFF:        return '{off:1, default:0};
            calc_pkg::B_MEM_RC:     return '{mem_rc:1, default:0};
            calc_pkg::B_MEM_SUB:    return '{mem_sub:1, default:0};
            calc_pkg::B_MEM_ADD:    return '{mem_add:1, default:0};
            calc_pkg::B_OP_PERCENT: return '{op_percent:1, default:0};
            calc_pkg::B_OP_SQRT:    return '{op_sqrt:1, default:0};
            calc_pkg::B_OP_DIV:     return '{op_div:1, default:0};
            calc_pkg::B_OP_MUL:     return '{op_mul:1, default:0};
            calc_pkg::B_OP_SUB:     return '{op_sub:1, default:0};
            calc_pkg::B_OP_ADD:     return '{op_add:1, default:0};
            calc_pkg::B_OP_EQ:      return '{op_eq:1, default:0};
            calc_pkg::B_DOT:        return '{dot:1, default:0};
            calc_pkg::B_NUM_1:      return '{num_1:1, default:0};
            calc_pkg::B_NUM_2:      return '{num_2:1, default:0};
            calc_pkg::B_NUM_3:      return '{num_3:1, default:0};
            calc_pkg::B_NUM_4:      return '{num_4:1, default:0};
            calc_pkg::B_NUM_5:      return '{num_5:1, default:0};
            calc_pkg::B_NUM_6:      return '{num_6:1, default:0};
            calc_pkg::B_NUM_7:      return '{num_7:1, default:0};
            calc_pkg::B_NUM_8:      return '{num_8:1, default:0};
            calc_pkg::B_NUM_9:      return '{num_9:1, default:0};
            calc_pkg::B_NUM_0:      return '{num_0:1, default:0};
            default:                return '{default:0};
        endcase
    endfunction

    `endif
endpackage

`endif
