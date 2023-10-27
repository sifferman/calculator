
module alu_add_tb import dv_pkg::*;;


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
always @* alu_add_result_q = num2real(dut.result_o);


// Clock Generation
initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end


// randomizer
// class packet;
//     rand calc_pkg::num_t num;
//     constraint c_error {
//         num.error == 0;
//     }
//     constraint c_exponent { num.exponent inside {
//         0, 0, 0, 0, 0, 0, 0, 0,
//         1, 2, 3, 4, 5, 6, 7, 8,
//         9, 9, 9, 9, 9, 9, 9, 9
//     }; }
//     constraint c_subnormal {
//         if (num.exponent == 0)
//             num.significand[calc_pkg::NumDigits-1] != 0;
//     }
//     constraint c_significand {
//         foreach (num.significand[i])
//             num.significand[i] inside {
//                 0, 0, 0, 0, 0, 0, 0, 0, 0,
//                 1, 2, 3, 4, 5, 6, 7, 8, 9
//             };
//     }
// endclass
function automatic calc_pkg::num_t packet();
    calc_pkg::num_t num;
    num.sign = $urandom_range(0,1);
    num.error = 0;
    case ($urandom_range(0,3))
        0: num.exponent = 0;
        1: num.exponent = 0;
        2: num.exponent = $urandom_range(1,6);
        3: num.exponent = 7;
    endcase
    for (integer j = 0; j < calc_pkg::NumDigits; j++) begin
        case ($urandom_range(0,1))
            0: num.significand[j] = 0;
            1: num.significand[j] = $urandom_range(1, 9);
        endcase
    end
    if (num.exponent != 0)
        num.significand[calc_pkg::NumDigits-1] = $urandom_range(1, 9);
    return num;
endfunction


// driver
always @(posedge clk_i) if (!rst_i) begin : driver
    // wait until adder is ready for input
    in_valid <= 0;
    while (!in_ready)
        @(posedge clk_i);

    // generate random input
    left <= packet();
    right <= packet();

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
    while (!out_valid)
        @(posedge clk_i);
    out_ready <= 0;

    num_tests <= num_tests+1;
end


// Test
property sum_is_correct();
    @(negedge clk_i)
    (out_ready && out_valid) |->
    (num_add(left, right) == result)
endproperty

integer tests_failed = 0;
assert property(sum_is_correct) else begin
    tests_failed <= tests_failed+1;
    $display(
        "%s + %s != %s : expected=%s : time=%t",
        num2string(left),
        num2string(right),
        num2string(result),
        num2string(num_add(left, right)),
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
