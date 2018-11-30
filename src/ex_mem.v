`include "defines.v"

module ex_mem (
    input   wire                clk,
    input   wire                rst,

    input   wire[`RegAddrBus]   ex_waddr,
    input   wire                ex_we,
    input   wire[`RegBus]       ex_wdata,

    output  reg[`RegAddrBus]    mem_waddr,
    output  reg                 mem_we,
    output  reg[`RegBus]        mem_wdata
);

    always @ (posedge clk) begin
        if (rst) begin
            mem_waddr <= 0;
            mem_we <= 0;
            mem_wdata <= 0;
        end else begin
            mem_waddr <= ex_waddr;
            mem_we <= ex_we;
            mem_wdata <= ex_wdata;
        end
    end

endmodule