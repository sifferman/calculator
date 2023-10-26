
module calculator #(
    NumDigits = 8
) (
    input   logic                   clk_i,
    input   logic                   rst_i,
    input   calc_pkg::buttons_t     buttons_i,
    output  logic [8*NumDigits-1:0] display_segments_o,
    output  calc_pkg::num_t         display_o
);

calc_pkg::active_button_t   active_button;
logic                       new_input;

logic           display_we;
calc_pkg::num_t display_wdata;
calc_pkg::num_t display_rdata;

assign display_o = display_rdata;

logic           upper_we;
calc_pkg::num_t upper_wdata;
calc_pkg::num_t upper_rdata;

calc_pkg::num_t alu_left;
calc_pkg::num_t alu_right;
calc_pkg::op_t  alu_op;
calc_pkg::num_t alu_result;

sanitize_buttons sanitize_buttons (
    .clk_i,
    .rst_i,
    .buttons_i,
    .new_input_o(new_input),
    .active_button_o(active_button)
);

num_register display (
    .clk_i,
    .rst_i,
    .we_i(display_we),
    .wdata_i(display_wdata),
    .rdata_o(display_rdata)
);

controller controller (
    .clk_i,
    .rst_i,
    .active_button_i(active_button),
    .new_input_i(new_input),

    .display_we_o(display_we),
    .display_wdata_o(display_wdata),
    .display_rdata_i(display_rdata),

    .upper_we_o(upper_we),
    .upper_wdata_o(upper_wdata),
    .upper_rdata_i(upper_rdata),

    .alu_left_o(alu_left),
    .alu_right_o(alu_right),
    .alu_op_o(alu_op),
    .alu_result_i(alu_result)
);

num_register upper (
    .clk_i,
    .rst_i,
    .we_i(upper_we),
    .wdata_i(upper_wdata),
    .rdata_o(upper_rdata)
);

alu alu (
    .clk_i,
    .rst_i,
    .left_i(alu_left),
    .right_i(alu_right),
    .op_i(alu_op),
    .result_o(alu_result)
);

endmodule
