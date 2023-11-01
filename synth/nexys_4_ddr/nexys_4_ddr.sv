
module nexys_4_ddr (
    input   logic               clk100mhz_i,
    input   logic               rst_ni,

    input   logic [15:0]        switches_i,

    output  logic [7:0]         segments_cathode_o,
    output  logic [7:0]         segments_anode_o

    ,output logic [15:0]        led_o
);

// read in switches as buttons
calc_pkg::buttons_t buttons;
always_comb begin
    buttons = '0;
    buttons.num_0 = switches_i[0];
    buttons.num_1 = switches_i[1];
    buttons.num_2 = switches_i[2];
    buttons.num_3 = switches_i[3];
    buttons.num_4 = switches_i[4];
    buttons.num_5 = switches_i[5];
    buttons.num_6 = switches_i[6];
    buttons.num_7 = switches_i[7];
    buttons.num_8 = switches_i[8];
    buttons.num_9 = switches_i[9];
    buttons.dot = switches_i[10];
    buttons.op_eq = switches_i[11];
    buttons.op_sub = switches_i[12];
    buttons.op_add = switches_i[13];
    buttons.op_mul = switches_i[14];
    buttons.op_div = switches_i[15];
end

// DEBUG: display currently active operation
always_comb begin
    led_o = '0;
    priority case (1)
        buttons.clear:      led_o = calc_pkg::B_CLEAR;
        buttons.mem_recall: led_o = calc_pkg::B_MEM_RECALL;
        buttons.mem_clear:  led_o = calc_pkg::B_MEM_CLEAR;
        buttons.mem_sub:    led_o = calc_pkg::B_MEM_SUB;
        buttons.mem_add:    led_o = calc_pkg::B_MEM_ADD;
        buttons.op_percent: led_o = calc_pkg::B_OP_PERCENT;
        buttons.op_sqrt:    led_o = calc_pkg::B_OP_SQRT;
        buttons.op_div:     led_o = calc_pkg::B_OP_DIV;
        buttons.op_mul:     led_o = calc_pkg::B_OP_MUL;
        buttons.op_sub:     led_o = calc_pkg::B_OP_SUB;
        buttons.op_add:     led_o = calc_pkg::B_OP_ADD;
        buttons.op_eq:      led_o = calc_pkg::B_OP_EQ;
        buttons.dot:        led_o = calc_pkg::B_DOT;
        buttons.num_1:      led_o = calc_pkg::B_NUM_1;
        buttons.num_2:      led_o = calc_pkg::B_NUM_2;
        buttons.num_3:      led_o = calc_pkg::B_NUM_3;
        buttons.num_4:      led_o = calc_pkg::B_NUM_4;
        buttons.num_5:      led_o = calc_pkg::B_NUM_5;
        buttons.num_6:      led_o = calc_pkg::B_NUM_6;
        buttons.num_7:      led_o = calc_pkg::B_NUM_7;
        buttons.num_8:      led_o = calc_pkg::B_NUM_8;
        buttons.num_9:      led_o = calc_pkg::B_NUM_9;
        buttons.num_0:      led_o = calc_pkg::B_NUM_0;
        default:            led_o = calc_pkg::B_NONE;
    endcase
end

// generate clock
logic clk1khz;
clk_divider #(
    .IN_FREQ(100000),
    .OUT_FREQ(1)
) clk_divider (
    .clk_i(clk100mhz_i),
    .rst_i(0),
    .clk_o(clk1khz)
);

// design
calculator calculator (
    .clk_i(clk1khz),
    .rst_i(!rst_ni),
    .buttons_i(buttons),
    .segments_cathode_o(segments_cathode_o),
    .segments_anode_o(segments_anode_o)
);

endmodule
