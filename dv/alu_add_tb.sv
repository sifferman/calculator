
module alu_add_tb;


logic           clk_i;
logic           rst_i;

calc_pkg::num_t left;
calc_pkg::num_t right;
logic           in_ready;
logic           in_valid;

calc_pkg::num_t result;
logic           out_ready;
logic           out_valid;

alu_add dut (
    .clk_i,
    .rst_i,

    .left_i(left),
    .right_i(right),
    .in_ready_o(in_ready),
    .in_valid_i(in_valid),

    .result_o(result),
    .out_ready_i(out_ready),
    .out_valid_o(out_valid)
);

real alu_add_result_q;
always_comb alu_add_result_q = dv_pkg::num2real(dut.result_o);


// Clock Generation
initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end


// driver
always @(posedge clk_i) if (!rst_i) begin : driver
    // wait until adder is ready for input
    in_valid <= 0;
    while (!in_ready)
        @(posedge clk_i);

    // generate random input
    left <= dv_pkg::random_num();
    right <= dv_pkg::random_num();

    // send data
    in_valid <= 1;
    @(posedge clk_i);
    in_valid <= 0;
end


// monitor
integer num_tests = 0;
always @(posedge clk_i) if (!rst_i) begin : monitor
    // wait until adder output is valid
    out_ready <= 1;
    while (!out_valid || !out_ready)
        @(posedge clk_i);
    out_ready <= 0;

    num_tests <= num_tests+1;
end


// Test
property sum_is_correct();
    @(negedge clk_i)
    (out_ready && out_valid) |->
    (alu_model_pkg::num_add(left, right) == result)
endproperty

integer tests_failed = 0;
assert property(sum_is_correct) else begin
    tests_failed <= tests_failed+1;
    $display(
        "%s + %s != %s : expected=%s : time=%t",
        dv_pkg::num2string(left),
        dv_pkg::num2string(right),
        dv_pkg::num2string(result),
        dv_pkg::num2string(alu_model_pkg::num_add(left, right)),
        $time
    );
    $fatal();
end


// Run
initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );

    rst_i = 1;
    @(negedge clk_i);
    @(negedge clk_i);
    rst_i = 0;

    repeat(10000000) @(posedge clk_i);
    $display("%0d/%0d tests passed", num_tests-tests_failed, num_tests);
    $finish();
end

endmodule
