
package calc_pkg;

    typedef struct packed {
        logic clear;

        logic mem_recall;
        logic mem_clear;
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
        B_NONE,
        B_CLEAR,
        B_MEM_RECALL,
        B_MEM_CLEAR,
        B_MEM_SUB,
        B_MEM_ADD,
        B_OP_PERCENT,
        B_OP_SQRT,
        B_OP_DIV,
        B_OP_MUL,
        B_OP_SUB,
        B_OP_ADD,
        B_OP_EQ,
        B_DOT,
        B_NUM_1,
        B_NUM_2,
        B_NUM_3,
        B_NUM_4,
        B_NUM_5,
        B_NUM_6,
        B_NUM_7,
        B_NUM_8,
        B_NUM_9,
        B_NUM_0,
        B_UNKNOWN
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

/*

  6      -           -     -           -     -     -     -     -
 1 5    | |     |     |     |   | |   |     |       |   | |   | |
  0                  -     -     -     -     -           -     -
 2 4    | |     |   |       |     |     |   | |     |   | |     |
  3      -           -     -           -     -           -     -

*/
    function automatic logic [6:0] bcd2segments(logic [3:0] bcd);
        logic [6:0] segments = 7'b1111011;
        unique case (bcd)
            4'd0: segments = 7'b1111110;
            4'd1: segments = 7'b0110000;
            4'd2: segments = 7'b1101101;
            4'd3: segments = 7'b1111001;
            4'd4: segments = 7'b0110011;
            4'd5: segments = 7'b1011011;
            4'd6: segments = 7'b1011111;
            4'd7: segments = 7'b1110000;
            4'd8: segments = 7'b1111111;
            4'd9: segments = 7'b1111011;
            default: segments = 7'b1111011;
        endcase
        return segments;
    endfunction




    typedef enum logic [2:0] {
        OP_NONE,
        OP_ADD,
        OP_SUB,
        OP_MUL,
        OP_DIV
    } op_t;

    function automatic op_t button2op(active_button_t active_button);
        unique case (active_button)
            calc_pkg::B_OP_DIV: return OP_DIV;
            calc_pkg::B_OP_MUL: return OP_MUL;
            calc_pkg::B_OP_SUB: return OP_SUB;
            calc_pkg::B_OP_ADD: return OP_ADD;
            default: return OP_NONE;
        endcase
    endfunction

    function automatic logic [3:0] button2bcd(active_button_t active_button);
        unique case (active_button)
            calc_pkg::B_NUM_1: return 1;
            calc_pkg::B_NUM_2: return 2;
            calc_pkg::B_NUM_3: return 3;
            calc_pkg::B_NUM_4: return 4;
            calc_pkg::B_NUM_5: return 5;
            calc_pkg::B_NUM_6: return 6;
            calc_pkg::B_NUM_7: return 7;
            calc_pkg::B_NUM_8: return 8;
            calc_pkg::B_NUM_9: return 9;
            calc_pkg::B_NUM_0: return 0;
            default: return 0;
        endcase
    endfunction

    parameter NumDigits = 8;

    typedef struct packed {
        logic sign;
        logic error;
        logic [$clog2(NumDigits)-1:0] exponent;
        logic [NumDigits-1:0][3:0] significand;
    } num_t;

    function automatic string num2string(num_t num);
        return $sformatf(
            "%0d.%0d%0d%0d%0d%0d%0d%0d x 10^%0d",
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



endpackage
