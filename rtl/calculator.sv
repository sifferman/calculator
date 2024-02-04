
module calculator (
    input   logic                                   clk_i,
    input   logic                                   rst_i,
    input   calc_pkg::buttons_t                     buttons_i,

    output  logic [calc_pkg::NumDigits-1:0][7:0]    display_segments_o,
    output  calc_pkg::num_t                         display_o,
    output  logic [7:0]                             segments_cathode_o,
    output  logic [calc_pkg::NumDigits-1:0]         segments_anode_o
);

calc_pkg::active_button_t   active_button;
logic                       new_input;

logic           override_shift_amount;
logic [2:0]     new_shift_amount;

calc_pkg::num_t alu_left;
calc_pkg::num_t alu_right;
calc_pkg::op_t  alu_op;
logic alu_in_ready;
logic alu_in_valid;

calc_pkg::num_t alu_result;
logic alu_out_ready;
logic alu_out_valid;

sanitize_buttons sanitize_buttons (
    .clk_i,
    .rst_i,
    .buttons_i,
    .new_input_o(new_input),
    .active_button_o(active_button)
);

controller controller (
    .clk_i,
    .rst_i,
    .active_button_i(active_button),
    .new_input_i(new_input),

    .override_shift_amount_o(override_shift_amount),
    .new_shift_amount_o(new_shift_amount),
    .display_data_o(display_o),

    .alu_left_o(alu_left),
    .alu_right_o(alu_right),
    .alu_op_o(alu_op),
    .alu_in_ready_i(alu_in_ready),
    .alu_in_valid_o(alu_in_valid),

    .alu_result_i(alu_result),
    .alu_out_ready_o(alu_out_ready),
    .alu_out_valid_i(alu_out_valid)
);

alu alu (
    .clk_i,
    .rst_i,
    .left_i(alu_left),
    .right_i(alu_right),
    .op_i(alu_op),
    .in_ready_o(alu_in_ready),
    .in_valid_i(alu_in_valid),
    .result_o(alu_result),
    .out_ready_i(alu_out_ready),
    .out_valid_o(alu_out_valid)
);

screen_driver screen_driver (
    .clk_i,
    .rst_i,
    .num_i(display_o),
    .override_shift_amount_i(override_shift_amount),
    .new_shift_amount_i(new_shift_amount),
    .display_segments_o(display_segments_o),
    .segments_cathode_o(segments_cathode_o),
    .segments_anode_o(segments_anode_o)
);

endmodule
