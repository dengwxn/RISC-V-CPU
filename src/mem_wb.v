`include "defines.v"

module mem_wb (
    input   wire                clk,
    input   wire                rst,

    input   wire[`RegAddrBus]   mem_waddr,
    input   wire                mem_we,
    input   wire[`RegBus]       mem_wdata,

    output  reg[`RegAddrBus]    wb_waddr,
    output  reg                 wb_we,
    output  reg[`RegBus]        wb_wdata,

    input   wire[4 : 0]         stall
);

    always @ (posedge clk) begin
        if (rst) begin
            wb_waddr <= 0;
            wb_we <= 0;
            wb_wdata <= 0;
        end else if (!stall[4]) begin
            wb_waddr <= mem_waddr;
            wb_we <= mem_we;
            wb_wdata <= mem_wdata;
        end
    end

endmodule