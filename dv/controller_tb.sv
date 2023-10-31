
module controller_tb import calc_pkg::*;;

logic                       clk_i;
logic                       rst_i;

calc_pkg::active_button_t   active_button = calc_pkg::B_NONE;
logic                       new_input = 0;

logic           override_shift_amount;
logic [2:0]     new_shift_amount;
logic [calc_pkg::NumDigits-1:0][7:0] display_segments;


logic           display_we;
calc_pkg::num_t display_wdata;
calc_pkg::num_t display_rdata;

logic           upper_we;
calc_pkg::num_t upper_wdata;
calc_pkg::num_t upper_rdata;

calc_pkg::num_t alu_left;
calc_pkg::num_t alu_right;
calc_pkg::op_t  alu_op;
logic alu_in_ready;
logic alu_in_valid;

calc_pkg::num_t alu_result;
logic alu_out_ready;
logic alu_out_valid;

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

    .override_shift_amount_o(override_shift_amount),
    .new_shift_amount_o(new_shift_amount),

    .display_we_o(display_we),
    .display_wdata_o(display_wdata),
    .display_rdata_i(display_rdata),

    .upper_we_o(upper_we),
    .upper_wdata_o(upper_wdata),
    .upper_rdata_i(upper_rdata),

    .alu_left_o(alu_left),
    .alu_right_o(alu_right),
    .alu_op_o(alu_op),
    .alu_in_ready_i(alu_in_ready),
    .alu_in_valid_o(alu_in_valid),

    .alu_result_i(alu_result),
    .alu_out_ready_o(alu_out_ready),
    .alu_out_valid_i(alu_out_valid)
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
    .in_ready_o(alu_in_ready),
    .in_valid_i(alu_in_valid),
    .result_o(alu_result),
    .out_ready_i(alu_out_ready),
    .out_valid_o(alu_out_valid)
);

screen_driver screen_driver (
    .num_i(display_rdata),
    .override_shift_amount_i(override_shift_amount),
    .new_shift_amount_i(new_shift_amount),
    .display_segments_o(display_segments)
);

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end

typedef struct {
    int size;
    calc_pkg::active_button_t in[$];
    calc_pkg::bcd_t display[$];
    calc_pkg::bcd_t upper[$];
    calc_pkg::bcd_t alu[$];
} test_t;

test_t expected[$] = '{
    test_t'{
        7,
        '{B_NUM_1, B_OP_ADD, B_OP_EQ, B_OP_EQ, B_OP_EQ, B_OP_EQ, B_OP_EQ},
        '{1, 1, 1, 2, 3, 4, 5},
        '{0, 0, 1, 1, 1, 1, 1},
        '{1, 1, 2, 3, 4, 5, 6}
    },test_t'{
        6,
        '{B_NUM_3, B_OP_EQ, B_NUM_1, B_OP_ADD, B_OP_EQ, B_OP_EQ},
        '{3, 3, 1, 1, 1, 2},
        '{0, 0, 0, 0, 1, 1},
        '{3, 3, 1, 1, 2, 3}
    },test_t'{
        10,
        '{B_OP_ADD, B_NUM_3, B_OP_EQ, B_NUM_1, B_OP_ADD, B_OP_EQ, B_OP_EQ, B_OP_EQ, B_OP_EQ, B_OP_EQ},
        '{0, 3, 3, 1, 1, 4, 5, 6, 7, 8},
        '{0, 0, 3, 3, 3, 1, 1, 1, 1, 1},
        '{0, 3, 6, 4, 4, 5, 6, 7, 8, 9}
    },test_t'{
        11,
        '{B_NUM_1, B_OP_ADD, B_NUM_1, B_OP_EQ, B_OP_ADD, B_OP_EQ, B_OP_ADD, B_OP_EQ, B_OP_ADD, B_OP_EQ, B_OP_ADD},
        '{1, 1, 1, 2, 2, 3, 3, 5, 5, 8, 8},
        '{},
        '{}
    },test_t'{
        6,
        '{B_NUM_1, B_OP_EQ, B_OP_EQ, B_OP_EQ, B_OP_EQ, B_OP_EQ, B_OP_EQ},
        '{1, 1, 1, 1, 1, 1},
        '{},
        '{}
    }
};



initial begin
    repeat(1000) @(posedge clk_i);
    $display("Timed out");
    $fatal;
end



initial begin
    logic ERROR = 0;

    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );

    for (integer test_i = 0; test_i < expected.size(); test_i++) begin
        calc_pkg::bcd_t recieved_display[$] = '{ };
        calc_pkg::bcd_t recieved_upper[$] = '{ };
        calc_pkg::bcd_t recieved_alu[$] = '{ };

        new_input = 0;
        rst_i = 1;
        @(negedge clk_i);
        @(negedge clk_i);
        rst_i = 0;
        new_input = 0;

        for (integer i = 0; i < expected[test_i].size; i++) begin
            num_t recieved_display_num;
            num_t recieved_upper_num;
            num_t recieved_alu_num;

            // wait for alu to be ready
            while (controller.state_q != 0)
                @(negedge clk_i);

            // send new input
            active_button = expected[test_i].in[i];
            new_input = 1;
            @(negedge clk_i);
            new_input = 0;

            // wait for operation to finish
            while (controller.state_q != 0)
                @(negedge clk_i);

            recieved_display_num = num_t'(controller.display_rdata_i);
            recieved_display.push_back(recieved_display_num.significand[7]);

            recieved_upper_num = num_t'(controller.upper_rdata_i);
            recieved_upper.push_back(recieved_upper_num.significand[7]);

            recieved_alu_num = num_t'(controller.alu_result_i);
            recieved_alu.push_back(recieved_alu_num.significand[7]);

            dv_pkg::print_segments(display_segments);
        end
        $display("recieved_display: %p", recieved_display);
        $display("expected.display: %p", expected[test_i].display);
        if (recieved_display != expected[test_i].display) begin
            $display("Mismatch"); ERROR = 1;
        end
        $display("recieved_upper: %p", recieved_upper);
        $display("expected.upper: %p", expected[test_i].upper);
        if (recieved_display != expected[test_i].display) begin
            $display("Mismatch"); ERROR = 1;
        end
        $display("recieved_alu: %p", recieved_alu);
        $display("expected.alu: %p", expected[test_i].alu);
        if (recieved_display != expected[test_i].display) begin
            $display("Mismatch"); ERROR = 1;
        end
        $display("");
    end
    if (ERROR) begin
        $fatal();
    end else begin
        $display("All passed!");
        $finish();
    end
end

endmodule
