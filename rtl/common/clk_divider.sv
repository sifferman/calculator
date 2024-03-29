
// https://www.desmos.com/calculator/6ogzgfkshu
module clk_divider #(
    parameter real IN_FREQ  = 1.0,
    parameter real OUT_FREQ = 1.0
) (
    input   logic   clk_i,
    input   logic   rst_i,
    output  logic   clk_o
);

    localparam COUNTER_RESET = $rtoi( 1.0 * IN_FREQ / OUT_FREQ );
    localparam ACTUAL_FREQ_MHz = IN_FREQ / COUNTER_RESET;

    generate if ( IN_FREQ <= ACTUAL_FREQ_MHz ) begin

        assign clk_o = clk_i;

    end else begin

        typedef logic [$clog2(COUNTER_RESET):0] counter_t;
        counter_t counter_d, counter_q;

        assign counter_d = (counter_q == counter_t'(COUNTER_RESET-1)) ? ('0) : (counter_q+1);
        initial counter_q = '0;

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                counter_q <= '0;
            end else begin
                counter_q <= counter_d;
            end
        end

        logic clk_d, clk_q;
        initial clk_q = 0;

        assign clk_d = ( counter_q > counter_t'($rtoi( COUNTER_RESET / 2.0 ) ));
        assign clk_o = clk_q;

        always_ff @(posedge clk_i) begin
            clk_q <= clk_d;
        end

    end endgenerate

endmodule
