
module screen_driver (
    input   logic                                   clk_i,
    input   logic                                   rst_i,

    input   calc_pkg::num_t                         num_i,
    input   logic                                   override_shift_amount_i,
    input   logic [2:0]                             new_shift_amount_i,
    output  logic [calc_pkg::NumDigits-1:0][7:0]    display_segments_o,

    output  logic [7:0]                             segments_cathode_o,
    output  logic [calc_pkg::NumDigits-1:0]         segments_anode_o
);


logic [2:0] shift_amount;

logic [2:0] num_fractional_digits;
assign num_fractional_digits = (calc_pkg::NumDigits-1 - num_i.exponent);

logic [2:0] num_decimal_places;
assign num_decimal_places = (num_fractional_digits - shift_amount);

always_comb begin : set_shift_amount
    integer i;
    i = '0;
    if (override_shift_amount_i) begin
        shift_amount = new_shift_amount_i;
    end else begin
        shift_amount = num_fractional_digits;
        for (i = calc_pkg::NumDigits-1; i >= 0; i--) begin
            if ((num_i.significand[i] != 0) && (i < num_fractional_digits))
                shift_amount = i;
        end
    end
end

always_comb begin : set_display_segments
    display_segments_o = '0;
    for (integer i = 0; i < calc_pkg::NumDigits; i++) begin
        if (calc_pkg::NumDigits-1 - i >= shift_amount)
            display_segments_o[i] = calc_pkg::bcd2segments(num_i.significand[i+shift_amount]);
    end
    display_segments_o[num_decimal_places][7] = 1;
end


// Driver for Nexys A7 Seven-Segment-Display

logic [$clog2(calc_pkg::NumDigits)-1:0] segments_counter_d, segments_counter_q;
logic [calc_pkg::NumDigits-1:0]         segments_anode_d, segments_anode_q;

assign segments_cathode_o = ~display_segments_o[segments_counter_q];
assign segments_anode_o = (rst_i ? '1 : segments_anode_q);

always_comb begin
    segments_anode_d = {segments_anode_q, segments_anode_q[calc_pkg::NumDigits-1]};
end
always_comb begin
    segments_counter_d = (segments_counter_q + 1);
    if (segments_counter_d == calc_pkg::NumDigits)
        segments_counter_d = 0;
end

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        segments_counter_q <= 0;
        segments_anode_q <= ~1;
    end else begin
        segments_counter_q <= segments_counter_d;
        segments_anode_q <= segments_anode_d;
    end
end

endmodule
