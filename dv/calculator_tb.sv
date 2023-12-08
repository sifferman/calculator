
module calculator_tb import calc_pkg::*;;

logic               clk_i;
logic               rst_i;
calc_pkg::buttons_t buttons_i;
logic [calc_pkg::NumDigits-1:0][7:0] display_segments;

calculator calculator (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .buttons_i(buttons_i),
    .display_segments_o(display_segments)
);

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end




initial begin
    repeat(1000) @(posedge clk_i);
    $display("Timed out");
    $fatal;
end

calc_pkg::num_t expected;



real alu_left;
real alu_right;
real alu_result;
real display_wdata;
real display_rdata;
real upper_wdata;
real upper_rdata;
real expected_real;
calc_pkg::active_button_t active_button;
always_comb begin
    alu_left = dv_pkg::num2real(calculator.alu.left_i);
    alu_right = dv_pkg::num2real(calculator.alu.right_i);
    alu_result = dv_pkg::num2real(calculator.alu.result_o);
    display_wdata = dv_pkg::num2real(calculator.display.wdata_i);
    display_rdata = dv_pkg::num2real(calculator.display.rdata_o);
    upper_wdata = dv_pkg::num2real(calculator.upper.wdata_i);
    upper_rdata = dv_pkg::num2real(calculator.upper.rdata_o);
    active_button = calc_pkg::active_button_t'(calculator.active_button);
    expected_real = dv_pkg::num2real(expected);
end

integer f;
integer fscan_status;
string button_string;

initial begin
    logic ERROR = 0;
    f = $fopen("dv/tests.mem", "r");

    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );

    rst_i = 1;
    @(negedge clk_i);
    @(negedge clk_i);
    rst_i = 0;

    while (!$feof(f)) begin

        logic                               expected_error;
        logic                               expected_sign;
        logic [(calc_pkg::NumDigits*4)-1:0] expected_significand;
        logic [2:0]                         expected_exponent;

        // wait for alu to be ready
        while (calculator.controller.state_q != 0)
            @(negedge clk_i);

        fscan_status = $fscanf(f, "%s %b %b %h %o \n", button_string, expected_error, expected_sign, expected_significand, expected_exponent);
        expected.error = expected_error;
        expected.sign = expected_sign;
        expected.significand = expected_significand;
        expected.exponent = expected_exponent;

        unique case (button_string)
            "ON":   buttons_i = '{on:1, default:0};
            "OFF":  buttons_i = '{off:1, default:0};
            "MRC":  buttons_i = '{mem_rc:1, default:0};
            "M-":   buttons_i = '{mem_sub:1, default:0};
            "M+":   buttons_i = '{mem_add:1, default:0};
            "\%":   buttons_i = '{op_percent:1, default:0};
            "SQ":   buttons_i = '{op_sqrt:1, default:0};
            "/":    buttons_i = '{op_div:1, default:0};
            "*":    buttons_i = '{op_mul:1, default:0};
            "-":    buttons_i = '{op_sub:1, default:0};
            "+":    buttons_i = '{op_add:1, default:0};
            "=":    buttons_i = '{op_eq:1, default:0};
            ".":    buttons_i = '{dot:1, default:0};
            "1":    buttons_i = '{num_1:1, default:0};
            "2":    buttons_i = '{num_2:1, default:0};
            "3":    buttons_i = '{num_3:1, default:0};
            "4":    buttons_i = '{num_4:1, default:0};
            "5":    buttons_i = '{num_5:1, default:0};
            "6":    buttons_i = '{num_6:1, default:0};
            "7":    buttons_i = '{num_7:1, default:0};
            "8":    buttons_i = '{num_8:1, default:0};
            "9":    buttons_i = '{num_9:1, default:0};
            "0":    buttons_i = '{num_0:1, default:0};
            default:buttons_i = '{default:0};
        endcase

        // send new input
        @(negedge clk_i);
        // Reset
        buttons_i = dv_pkg::button2buttons(calc_pkg::B_NONE);
        @(negedge clk_i);

        // wait for operation to finish
        while (calculator.controller.state_q != 0)
            @(negedge clk_i);

        assert (expected == calculator.display.rdata_o)
        else begin
            $display("Expected: %s | Recieved: %s", dv_pkg::num2string(expected), dv_pkg::num2string(calculator.display.rdata_o));
            @(posedge clk_i);
            $fatal();
        end
    end

    $fclose(f);
    $finish();
end

endmodule
