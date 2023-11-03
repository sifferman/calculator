
module clk_divider (
    input   logic   clk_i,
    input   logic   rst_i,
    output  logic   clk_o
);

    logic [17:0] counter_d, counter_q;
    logic clk_d, clk_q;

    assign clk_o = clk_q;

    assign counter_d = (counter_q >= 99999) ? ('0) : (counter_q+1);
    assign clk_d = ( counter_q < 50000 );

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            counter_q <= '0;
        end else begin
            counter_q <= counter_d;
        end
    end
    always_ff @(posedge clk_i) begin
        clk_q <= clk_d;
    end


endmodule
