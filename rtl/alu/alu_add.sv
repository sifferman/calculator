
module alu_add (
    input   logic           clk_i,
    input   logic           rst_i,

    input   calc_pkg::num_t left_i,
    input   calc_pkg::num_t right_i,
    output  logic           in_ready_o,
    input   logic           in_valid_i,

    output  calc_pkg::num_t result_o,
    input   logic           out_ready_i,
    output  logic           out_valid_o
);

typedef enum logic [1:0] {
    S_IDLE,
    S_NORMALIZE,
    S_ADD,
    S_RENORMALIZE
} state_t;

state_t state_d, state_q;
logic [$clog2(calc_pkg::NumDigits):0] counter_d, counter_q;

logic in_ready_d, in_ready_q;
logic out_valid_d, out_valid_q;
assign out_valid_o = out_valid_q;
assign in_ready_o = in_ready_q;

calc_pkg::num_t left_d, left_q;
calc_pkg::num_t right_d, right_q;
calc_pkg::num_t result_d, result_q;
calc_pkg::bcd_t result_extra_d, result_extra_q;
logic carryborrow_d, carryborrow_q;

assign result_o = out_valid_q ? result_q : '0;

logic [4:0] nibble_sum;

// calculate per-nibble sum and carry
always_comb begin
    nibble_sum = 'x;
    carryborrow_d = carryborrow_q;

    if (state_q != S_ADD) begin
        carryborrow_d = 0;
    end else if (left_q.sign == right_q.sign) begin
        nibble_sum =
            left_q.significand[counter_q]
            + right_q.significand[counter_q]
            + 4'(carryborrow_q);
        if (nibble_sum >= 10) begin
            nibble_sum += 6;
        end
        carryborrow_d = nibble_sum[4];
    end else begin
        if (left_q.significand > right_q.significand) begin
            nibble_sum =
                6'(left_q.significand[counter_q])
                - 6'(right_q.significand[counter_q])
                - 6'(carryborrow_q);
        end else begin
            nibble_sum =
                6'(right_q.significand[counter_q])
                - 6'(left_q.significand[counter_q])
                - 6'(carryborrow_q);
        end
        carryborrow_d = nibble_sum[4];
        if ($signed(nibble_sum) < 0) begin
            nibble_sum += 10;
        end
    end
end

always_comb begin
    state_d = state_q;
    out_valid_d = out_valid_q;
    in_ready_d = in_ready_q;
    counter_d = counter_q;
    left_d = left_q;
    right_d = right_q;
    result_d = result_q;
    result_extra_d = result_extra_q;

    case (state_q)
        S_IDLE: begin
            result_d = '0;
            if (in_valid_i) begin
                left_d = left_i;
                right_d = right_i;
                state_d = S_NORMALIZE;
                in_ready_d = 0;
            end
        end
        S_NORMALIZE: begin
            if (left_q.exponent < right_q.exponent) begin
                left_d.significand = calc_pkg::rightshift_significand(4'b0, left_q.significand);
                left_d.exponent++;
            end else if (left_q.exponent > right_q.exponent) begin
                right_d.significand = calc_pkg::rightshift_significand(4'b0, right_q.significand);
                right_d.exponent++;
            end else begin
                state_d = S_ADD;
                counter_d = 0;
            end
        end
        S_ADD: begin
            result_d.exponent = left_q.exponent;

            if (left_q.sign == right_q.sign) begin
                result_extra_d = carryborrow_d;
            end

            if (left_q.significand > right_q.significand) begin
                result_d.sign = left_q.sign;
            end else begin
                result_d.sign = right_q.sign;
            end

            result_d.significand[counter_q] = 4'(nibble_sum);
            counter_d++;

            if (counter_d == calc_pkg::NumDigits) begin
                state_d = S_RENORMALIZE;
            end
        end
        S_RENORMALIZE: begin
            if (result_extra_q != '0) begin // shift right
                result_extra_d = '0;
                result_d.significand = calc_pkg::rightshift_significand(result_extra_q, result_q.significand);
                result_d.exponent++;
                if (result_d.exponent == 0)
                    result_d.error = 1;
            end else if ((result_q.exponent != 0) && (result_q.significand[calc_pkg::NumDigits-1] == 0)) begin // shift left
                result_d.significand = calc_pkg::leftshift_significand(result_q.significand, 4'b0);
                result_d.exponent--;
            end else begin // no shift
                out_valid_d = 1;
                in_ready_d = 1;
                if (result_d.significand == 0)
                    result_d.sign = 0;
                if (out_valid_q && out_ready_i) begin
                    state_d = S_IDLE;
                    out_valid_d = 0;
                    result_d = '0;
                end
            end
        end
    endcase
end


always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state_q <= S_IDLE;
        out_valid_q <= 0;
        in_ready_q <= 1;
        counter_q <= '0;
        left_q <= '0;
        right_q <= '0;
        result_q <= '0;
        result_extra_q <= '0;
        carryborrow_q <= 0;
    end else begin
        state_q <= state_d;
        out_valid_q <= out_valid_d;
        in_ready_q <= in_ready_d;
        counter_q <= counter_d;
        left_q <= left_d;
        right_q <= right_d;
        result_q <= result_d;
        result_extra_q <= result_extra_d;
        carryborrow_q <= carryborrow_d;
    end
end


endmodule
