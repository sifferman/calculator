
module num_register (
    input   logic           clk_i,
    input   logic           rst_i,

    input   logic           we_i,
    input   calc_pkg::num_t wdata_i,
    output  calc_pkg::num_t rdata_o
);

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        rdata_o <= '0;
    end else if (we_i) begin
        rdata_o <= wdata_i;
    end
end

endmodule
