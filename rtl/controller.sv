
module controller (
    input   logic                       clk_i,
    input   logic                       rst_i,
    input   calc_pkg::active_button_t   active_button_i,
    input   logic                       new_input_i,

    output  logic                       override_shift_amount_o,
    output  logic [2:0]                 new_shift_amount_o,

    output  logic                       display_we_o,
    output  calc_pkg::num_t             display_wdata_o,
    input   calc_pkg::num_t             display_rdata_i,

    output  logic                       upper_we_o,
    output  calc_pkg::num_t             upper_wdata_o,
    input   calc_pkg::num_t             upper_rdata_i,

    output  calc_pkg::num_t             alu_left_o,
    output  calc_pkg::num_t             alu_right_o,
    output  calc_pkg::op_t              alu_op_o,
    input   logic                       alu_in_ready_i,
    output  logic                       alu_in_valid_o,

    input   calc_pkg::num_t             alu_result_i,
    output  logic                       alu_out_ready_o,
    input   logic                       alu_out_valid_i
);


// Status Registers and Counters
logic                                   dot_recieved_d, dot_recieved_q;
logic                                   op_pending_d, op_pending_q;
logic [$clog2(calc_pkg::NumDigits):0]   display_counter_d, display_counter_q;
calc_pkg::op_t                          last_op_d, last_op_q;

// Intermediate helpers
logic [$clog2(calc_pkg::NumDigits):0] display_write_index;
assign display_write_index = calc_pkg::NumDigits-1 - display_counter_q;

logic new_number;
assign new_number = (display_counter_q == 0);

// ALU Interface
assign alu_left_o = upper_rdata_i;
assign alu_right_o = display_rdata_i;
assign alu_op_o = alu_op_q;
calc_pkg::op_t alu_op_d, alu_op_q;

logic alu_out_ready_d, alu_out_ready_q;
assign alu_out_ready_o = alu_out_ready_q;
logic alu_in_valid_d, alu_in_valid_q;
assign alu_in_valid_o = alu_in_valid_q;

typedef enum logic [1:0] {
    S_WAIT_FOR_INPUT,
    S_HANDLE_OP,
    S_HANDLE_EQ
} state_t;

state_t state_d, state_q;

// Display logic
assign override_shift_amount_o = (!new_number);
assign new_shift_amount_o = (calc_pkg::NumDigits - display_counter_q);

// Control Logic
always_comb begin
    op_pending_d = op_pending_q;
    last_op_d = last_op_q;
    alu_op_d = alu_op_q;

    display_counter_d = display_counter_q;
    dot_recieved_d = dot_recieved_q;

    display_wdata_o = 'x;
    display_we_o = 0;

    upper_wdata_o = 'x;
    upper_we_o = 0;

    alu_out_ready_d = alu_out_ready_q;
    alu_in_valid_d = alu_in_valid_q;

    state_d = state_q;


    if (state_q inside {S_HANDLE_OP, S_HANDLE_EQ}) begin
        if (alu_in_valid_q && alu_in_ready_i) begin // wait until in_ready
            alu_in_valid_d = 0;
            alu_out_ready_d = 1;
        end

        if (alu_out_ready_q && alu_out_valid_i) begin // wait until out_valid
            alu_out_ready_d = 0;
            state_d = S_WAIT_FOR_INPUT;
            if (state_q == S_HANDLE_OP) begin
                op_pending_d = 1;
                last_op_d = alu_op_q;
                if (op_pending_q) begin
                    display_wdata_o = alu_result_i;
                    display_we_o = 1;
                end
            end else if (state_q == S_HANDLE_EQ) begin
                op_pending_d = 0;
                display_wdata_o = alu_result_i;
                display_we_o = 1;
                if (op_pending_q) begin
                    upper_wdata_o = display_rdata_i;
                    upper_we_o = 1;
                end
            end
        end
    end else if (new_input_i) begin
        if (
            calc_pkg::isNumberButton(active_button_i) // a number was pressed
            && (display_counter_q < calc_pkg::NumDigits) // there is still space on the calculator
            && !((new_number) && (active_button_i == calc_pkg::B_NUM_0)) // it is not a preceding zero
        ) begin
            if (new_number) begin
                display_wdata_o = '0;
            end else begin
                display_wdata_o = display_rdata_i;
                if (!dot_recieved_q)
                    display_wdata_o.exponent++;
            end
            display_wdata_o.significand[display_write_index] = calc_pkg::button2bcd(active_button_i);
            display_we_o = 1;
            display_counter_d++;

            if (op_pending_q) begin
                upper_wdata_o = display_rdata_i;
                upper_we_o = 1;
            end
        end else if (calc_pkg::isDotButton(active_button_i)) begin
            if (new_number)
                display_counter_d++;
            dot_recieved_d = 1;
        end else if (calc_pkg::isOpButton(active_button_i)) begin
            alu_op_d = calc_pkg::button2op(active_button_i);
            alu_in_valid_d = 1;
            display_counter_d = '0;
            dot_recieved_d = 0;
            state_d = S_HANDLE_OP;
        end else if (calc_pkg::isEqButton(active_button_i)) begin
            alu_op_d = last_op_q;
            alu_in_valid_d = 1;
            display_counter_d = '0;
            dot_recieved_d = 0;
            state_d = S_HANDLE_EQ;
        end
    end
end

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        display_counter_q <= '0;
        last_op_q <= calc_pkg::OP_ADD;
        dot_recieved_q <= 0;
        op_pending_q <= 0;
        alu_out_ready_q <= 0;
        state_q <= S_WAIT_FOR_INPUT;
        alu_op_q <= calc_pkg::OP_ADD;
        alu_in_valid_q <= 0;
    end else begin
        display_counter_q <= display_counter_d;
        last_op_q <= last_op_d;
        dot_recieved_q <= dot_recieved_d;
        op_pending_q <= op_pending_d;
        alu_out_ready_q <= alu_out_ready_d;
        state_q <= state_d;
        alu_op_q <= alu_op_d;
        alu_in_valid_q <= alu_in_valid_d;
    end
end

endmodule
