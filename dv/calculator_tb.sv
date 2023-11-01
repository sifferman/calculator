
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

        rst_i = 1;
        @(negedge clk_i);
        @(negedge clk_i);
        rst_i = 0;

        for (integer i = 0; i < expected[test_i].size; i++) begin
            num_t recieved_display_num;
            num_t recieved_upper_num;
            num_t recieved_alu_num;

            // wait for alu to be ready
            while (calculator.controller.state_q != 0)
                @(negedge clk_i);

            // send new input
            buttons_i = dv_pkg::button2buttons(calc_pkg::B_NONE);
            @(negedge clk_i);
            buttons_i = dv_pkg::button2buttons(expected[test_i].in[i]);
            @(negedge clk_i);
            @(negedge clk_i);

            // wait for operation to finish
            while (calculator.controller.state_q != 0)
                @(negedge clk_i);

            recieved_display_num = num_t'(calculator.controller.display_rdata_i);
            recieved_display.push_back(recieved_display_num.significand[7]);

            recieved_upper_num = num_t'(calculator.controller.upper_rdata_i);
            recieved_upper.push_back(recieved_upper_num.significand[7]);

            recieved_alu_num = num_t'(calculator.controller.alu_result_i);
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
