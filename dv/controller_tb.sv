
module controller_tb import calc_pkg::*;;

logic                       clk_i;
logic                       rst_i;

calc_pkg::active_button_t   active_button = calc_pkg::B_NONE;
logic                       new_input = 0;

logic           display_we;
calc_pkg::num_t display_wdata;
calc_pkg::num_t display_rdata;

logic           upper_we;
calc_pkg::num_t upper_wdata;
calc_pkg::num_t upper_rdata;

calc_pkg::num_t alu_left;
calc_pkg::num_t alu_right;
calc_pkg::op_t  alu_op;
calc_pkg::num_t alu_result;

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

    .display_we_o(display_we),
    .display_wdata_o(display_wdata),
    .display_rdata_i(display_rdata),

    .upper_we_o(upper_we),
    .upper_wdata_o(upper_wdata),
    .upper_rdata_i(upper_rdata),

    .alu_left_o(alu_left),
    .alu_right_o(alu_right),
    .alu_op_o(alu_op),
    .alu_result_i(alu_result)
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
    .result_o(alu_result)
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
    logic [3:0] display[$];
    logic [3:0] upper[$];
    logic [3:0] alu[$];
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
    logic ERROR = 0;

    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );

    for (integer test_i = 0; test_i < expected.size(); test_i++) begin
        logic [3:0] recieved_display[$] = '{ };
        logic [3:0] recieved_upper[$] = '{ };
        logic [3:0] recieved_alu[$] = '{ };

        new_input = 0;
        rst_i = 1;
        @(negedge clk_i);
        @(negedge clk_i);
        rst_i = 0;
        new_input = 1;

        for (integer i = 0; i < expected[test_i].size; i++) begin
            num_t recieved_display_num;
            num_t recieved_upper_num;
            num_t recieved_alu_num;

            active_button = expected[test_i].in[i];
            @(negedge clk_i);

            recieved_display_num = num_t'(controller.display_rdata_i);
            recieved_display.push_back(recieved_display_num.significand[7]);

            recieved_upper_num = num_t'(controller.upper_rdata_i);
            recieved_upper.push_back(recieved_upper_num.significand[7]);

            recieved_alu_num = num_t'(controller.alu_result_i);
            recieved_alu.push_back(recieved_alu_num.significand[7]);
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