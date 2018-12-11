`include "defines.v"

module ex_mem (
    input   wire                clk,
    input   wire                rst,

    input   wire[`RegAddrBus]   ex_waddr,
    input   wire                ex_we,
    input   wire[`RegBus]       ex_wdata,

    output  reg[`RegAddrBus]    mem_waddr,
    output  reg                 mem_we,
    output  reg[`RegBus]        mem_wdata,

    input   wire[`MemAddrBus]   mem_addr_i,
    output  reg[`MemAddrBus]    mem_addr_o,
    input   wire[`AluOpBus]     mem_aluop_i,
    output  reg[`AluOpBus]      mem_aluop_o,
    input   wire[`RegBus]       rt_data_i,
    output  reg[`RegBus]        rt_data_o
);

    always @ (posedge clk) begin
        if (rst) begin
            mem_waddr <= 0;
            mem_we <= 0;
            mem_wdata <= 0;
            mem_addr_o <= 0;
            mem_aluop_o <= 0;
            rt_data_o <= 0;
        end else begin
            mem_waddr <= ex_waddr;
            mem_we <= ex_we;
            mem_wdata <= ex_wdata;
            mem_addr_o <= mem_addr_i;
            mem_aluop_o <= mem_aluop_i;
            rt_data_o <= rt_data_i;
        end
    end

endmodule