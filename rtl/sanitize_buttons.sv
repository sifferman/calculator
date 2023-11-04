
module sanitize_buttons (
    input   logic                       clk_i,
    input   logic                       rst_i,
    input   calc_pkg::buttons_t         buttons_i,
    output  logic                       new_input_o,
    output  calc_pkg::active_button_t   active_button_o
);

calc_pkg::buttons_t buttons_pressed_d, buttons_pressed_q;
assign buttons_pressed_d = buttons_i;

logic button_held_d, button_held_q;
assign button_held_d = ((buttons_i != '0) && (buttons_pressed_q != '0));

always_comb begin
    new_input_o = 0;
    active_button_o = calc_pkg::B_NONE;

    // freeze if a button was held
    if (!button_held_q) begin

        priority case (1)
            buttons_pressed_q.on:           active_button_o = calc_pkg::B_ON;
            buttons_pressed_q.off:          active_button_o = calc_pkg::B_OFF;
            buttons_pressed_q.mem_rc:       active_button_o = calc_pkg::B_MEM_RC;
            buttons_pressed_q.mem_sub:      active_button_o = calc_pkg::B_MEM_SUB;
            buttons_pressed_q.mem_add:      active_button_o = calc_pkg::B_MEM_ADD;
            buttons_pressed_q.op_percent:   active_button_o = calc_pkg::B_OP_PERCENT;
            buttons_pressed_q.op_sqrt:      active_button_o = calc_pkg::B_OP_SQRT;
            buttons_pressed_q.op_div:       active_button_o = calc_pkg::B_OP_DIV;
            buttons_pressed_q.op_mul:       active_button_o = calc_pkg::B_OP_MUL;
            buttons_pressed_q.op_sub:       active_button_o = calc_pkg::B_OP_SUB;
            buttons_pressed_q.op_add:       active_button_o = calc_pkg::B_OP_ADD;
            buttons_pressed_q.op_eq:        active_button_o = calc_pkg::B_OP_EQ;
            buttons_pressed_q.dot:          active_button_o = calc_pkg::B_DOT;
            buttons_pressed_q.num_1:        active_button_o = calc_pkg::B_NUM_1;
            buttons_pressed_q.num_2:        active_button_o = calc_pkg::B_NUM_2;
            buttons_pressed_q.num_3:        active_button_o = calc_pkg::B_NUM_3;
            buttons_pressed_q.num_4:        active_button_o = calc_pkg::B_NUM_4;
            buttons_pressed_q.num_5:        active_button_o = calc_pkg::B_NUM_5;
            buttons_pressed_q.num_6:        active_button_o = calc_pkg::B_NUM_6;
            buttons_pressed_q.num_7:        active_button_o = calc_pkg::B_NUM_7;
            buttons_pressed_q.num_8:        active_button_o = calc_pkg::B_NUM_8;
            buttons_pressed_q.num_9:        active_button_o = calc_pkg::B_NUM_9;
            buttons_pressed_q.num_0:        active_button_o = calc_pkg::B_NUM_0;
            default:                        active_button_o = calc_pkg::B_NONE;
        endcase

        new_input_o = (active_button_o != calc_pkg::B_NONE);
    end
end


always_ff @(posedge clk_i) begin
    if (rst_i) begin
        buttons_pressed_q <= '0;
        button_held_q <= 0;
    end else begin
        buttons_pressed_q <= buttons_pressed_d;
        button_held_q <= button_held_d;
    end
end


endmodule
