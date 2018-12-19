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

    input   wire[`DataAddrBus]  ex_mem_addr,
    input   wire[`AluOpBus]     ex_mem_aluop,
    input   wire[`RegBus]       ex_rt_data,

    output  reg[`DataAddrBus]   mem_mem_addr,
    output  reg[`AluOpBus]      mem_mem_aluop,
    output  reg[`RegBus]        mem_rt_data
);

    always @ (posedge clk) begin
        if (rst) begin
            mem_waddr <= 0;
            mem_we <= 0;
            mem_wdata <= 0;
            mem_mem_addr <= 0;
            mem_mem_aluop <= 0;
            mem_rt_data <= 0;
        end else begin
            mem_waddr <= ex_waddr;
            mem_we <= ex_we;
            mem_wdata <= ex_wdata;
            mem_mem_addr <= ex_mem_addr;
            mem_mem_aluop <= ex_mem_aluop;
            mem_rt_data <= ex_rt_data;
        end
    end

endmodule