
module screen_driver_tb;

calc_pkg::num_t                         num;
logic                                   override_shift_amount;
logic [2:0]                             new_shift_amount;
logic [calc_pkg::NumDigits-1:0][7:0]    display_segments;

screen_driver screen_driver (
    .num_i(num),
    .override_shift_amount_i(0),
    .new_shift_amount_i('x),
    .display_segments_o(display_segments)
);

initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    for (integer i = 0; i < 10; i++) begin
        num = dv_pkg::random_num();
        #1;
        $display(dv_pkg::num2string(num));
        dv_pkg::print_segments(display_segments);
    end
    $finish();
end

endmodule
