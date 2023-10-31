
module screen_driver (
    input   calc_pkg::num_t                         num_i,
    input   logic                                   override_shift_amount_i,
    input   logic [2:0]                             new_shift_amount_i,
    output  logic [calc_pkg::NumDigits-1:0][7:0]    display_segments_o
);


logic [2:0] num_decimal_places;
logic [2:0] shift_amount;

logic signed [31:0] i1;
always_comb begin
    i1 = 'x;
    num_decimal_places = 'x;
    shift_amount = 'x;

    if (override_shift_amount_i) begin
        shift_amount = new_shift_amount_i;
    end else begin
        num_decimal_places = '0;
        for (i1 = calc_pkg::NumDigits-1; i1 >= 0; i1--) begin
            if ((num_i.significand[i1] != 0) && (i1 < calc_pkg::NumDigits-1-num_i.exponent))
                num_decimal_places = calc_pkg::NumDigits-1-num_i.exponent-i1;
        end
        shift_amount = (calc_pkg::NumDigits-1 - num_i.exponent - num_decimal_places);
    end
end

logic signed [31:0] i2;
always_comb begin
    display_segments_o = '0;
    for (i2 = 0; i2 < calc_pkg::NumDigits; i2++) begin
        if (calc_pkg::NumDigits-1 - i2 >= shift_amount)
            display_segments_o[i2] = calc_pkg::bcd2segments(num_i.significand[i2+shift_amount]);
    end
    display_segments_o[num_decimal_places][7] = 1;
end

endmodule
