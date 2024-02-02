
`ifndef __CALC_PKG_SV
`define __CALC_PKG_SV

`define ABS(N) (($signed(N)<0)?(-(N)):((N)))

package calc_pkg;

    typedef struct packed {
        logic on;
        logic off;

        logic mem_rc;
        logic mem_sub;
        logic mem_add;

        logic op_percent;
        logic op_sqrt;
        logic op_div;
        logic op_mul;
        logic op_sub;
        logic op_add;
        logic op_eq;

        logic dot;

        logic num_1;
        logic num_2;
        logic num_3;
        logic num_4;
        logic num_5;
        logic num_6;
        logic num_7;
        logic num_8;
        logic num_9;
        logic num_0;
    } buttons_t;

    typedef enum logic [4:0] {
        B_NONE,         // 00000
        B_ON,           // 00001
        B_OFF,          // 00010
        B_MEM_RC,       // 00011
        B_MEM_SUB,      // 00100
        B_MEM_ADD,      // 00101
        B_OP_PERCENT,   // 00110
        B_OP_SQRT,      // 00111
        B_OP_DIV,       // 01000
        B_OP_MUL,       // 01001
        B_OP_SUB,       // 01010
        B_OP_ADD,       // 01011
        B_OP_EQ,        // 01100
        B_DOT,          // 01101
        B_NUM_1,        // 01110
        B_NUM_2,        // 01111
        B_NUM_3,        // 10000
        B_NUM_4,        // 10001
        B_NUM_5,        // 10010
        B_NUM_6,        // 10011
        B_NUM_7,        // 10100
        B_NUM_8,        // 10101
        B_NUM_9,        // 10110
        B_NUM_0,        // 10111
        B_UNKNOWN       // 11000
    } active_button_t;

    function automatic logic isNumberButton(active_button_t active_button);
        return active_button inside {
            B_NUM_1,
            B_NUM_2,
            B_NUM_3,
            B_NUM_4,
            B_NUM_5,
            B_NUM_6,
            B_NUM_7,
            B_NUM_8,
            B_NUM_9,
            B_NUM_0
        };
    endfunction

    function automatic logic isOpButton(active_button_t active_button);
        return active_button inside {
            B_OP_DIV,
            B_OP_MUL,
            B_OP_SUB,
            B_OP_ADD
        };
    endfunction

    function automatic logic isEqButton(active_button_t active_button);
        return (active_button == B_OP_EQ);
    endfunction

    function automatic logic isDotButton(active_button_t active_button);
        return (active_button == B_DOT);
    endfunction

    typedef logic [3:0] bcd_t;

/*

  6      -           -     -           -     -     -     -     -
 1 5    | |     |     |     |   | |   |     |       |   | |   | |
  0                  -     -     -     -     -           -     -
 2 4    | |     |   |       |     |     |   | |     |   | |     |
  3  7   -           -     -           -     -           -     -

*/
    function automatic logic [6:0] bcd2segments(bcd_t bcd);
        unique case (bcd)
            4'd0: return 7'b1111110;
            4'd1: return 7'b0110000;
            4'd2: return 7'b1101101;
            4'd3: return 7'b1111001;
            4'd4: return 7'b0110011;
            4'd5: return 7'b1011011;
            4'd6: return 7'b1011111;
            4'd7: return 7'b1110000;
            4'd8: return 7'b1111111;
            4'd9: return 7'b1111011;
            default: return 7'bxxxxxxx;
        endcase
    endfunction

    typedef enum logic [1:0] {
        OP_NONE,
        OP_ADD,
        OP_MUL,
        OP_DIV
    } op_t;

    function automatic op_t button2op(active_button_t active_button);
        unique case (active_button)
            B_OP_DIV: return OP_DIV;
            B_OP_MUL: return OP_MUL;
            B_OP_SUB: return OP_ADD;
            B_OP_ADD: return OP_ADD;
            default: return OP_NONE;
        endcase
    endfunction

    function automatic bcd_t button2bcd(active_button_t active_button);
        unique case (active_button)
            B_NUM_1: return 1;
            B_NUM_2: return 2;
            B_NUM_3: return 3;
            B_NUM_4: return 4;
            B_NUM_5: return 5;
            B_NUM_6: return 6;
            B_NUM_7: return 7;
            B_NUM_8: return 8;
            B_NUM_9: return 9;
            B_NUM_0: return 0;
            default: return 0;
        endcase
    endfunction

    parameter NumDigits = 8;

    typedef logic unsigned [$clog2(NumDigits)-1:0] exponent_t;

    typedef struct packed {
        logic error;
        logic sign;
        exponent_t exponent;
        bcd_t [NumDigits-1:0] significand;
    } num_t;

    function automatic num_t neg(num_t num);
        localparam num_t negative_zero = '{sign: 1, default: 0};
        return num ^ negative_zero;
    endfunction

endpackage

`endif
