
module screen_driver_tb;

logic                                   clk_i;
logic                                   rst_i;
calc_pkg::num_t                         num;
logic                                   override_shift_amount;
logic [2:0]                             new_shift_amount;
logic [calc_pkg::NumDigits-1:0][7:0]    display_segments;

logic [7:0]                             segments_cathode;
logic [calc_pkg::NumDigits-1:0]         segments_anode;

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i ^= 1;
    end
end

screen_driver screen_driver (
    .clk_i,
    .rst_i,
    .num_i(num),
    .override_shift_amount_i(0),
    .new_shift_amount_i('x)
);

real num_real;
always_comb num_real = dv_pkg::num2real(num);

initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    rst_i = 1;
    @(negedge clk_i);
    rst_i = 0;

    for (integer i = 0; i < 10; i++) begin
        num = dv_pkg::random_num();
        repeat (calc_pkg::NumDigits) @(negedge clk_i);
        $display(dv_pkg::num2string(num));
        dv_pkg::print_segments(screen_driver.display_segments_o);
    end
    $finish();
end

endmodule
