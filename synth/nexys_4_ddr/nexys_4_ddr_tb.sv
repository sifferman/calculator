
module nexys_4_ddr_tb;

logic               clk100mhz_i;
logic               rst_ni;
logic [15:0]        switches_i;

initial begin
    clk100mhz_i = 0;
    forever begin
        #1;
        clk100mhz_i = !clk100mhz_i;
    end
end

nexys_4_ddr nexys_4_ddr (
    .clk100mhz_i(clk100mhz_i),
    .rst_ni(rst_ni),
    .switches_i(switches_i)
);

initial begin
    #110000000;
    $display("Timed out");
    $fatal();
end

integer random;
initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );

    rst_ni = 0;
    #250000;
    rst_ni = 1;

    for (integer i = 0; i < 500; i++) begin
        random = $urandom_range(0, 3);
        if (random == 0) begin // no buttons pressed
            switches_i = '0;
        end else if (random == 1) begin // 2 buttons pressed
            switches_i = 1<<$urandom_range(0, 13);
            switches_i |= 1<<$urandom_range(0, 13);
        end else begin
            switches_i = 1<<$urandom_range(0, 13); // 1 button pressed
        end
        @(negedge nexys_4_ddr.clk1khz);
        dv_pkg::print_segments(nexys_4_ddr_tb.nexys_4_ddr.calculator.screen_driver.display_segments_o);
    end

    $finish;
end

calc_pkg::active_button_t active_button;
always_comb active_button = calc_pkg::active_button_t'(nexys_4_ddr_tb.nexys_4_ddr.calculator.active_button);

real num_real;
always_comb num_real = dv_pkg::num2real(nexys_4_ddr_tb.nexys_4_ddr.calculator.display_rdata);

endmodule
