// RISCV32I CPU top module
// port modification allowed for debugging purposes

`include "defines.v"

module cpu(
    input  wire         clk_in,		// system clock signal
    input  wire         rst_in,		// reset signal
	input  wire			rdy_in,		// ready signal, pause cpu when low

    input  wire [ 7:0]	mem_din,	// data input bus
    output wire [ 7:0]  mem_dout,	// data output bus
    output wire [31:0]  mem_a,		// address bus (only 17:0 is used)
    output wire         mem_wr,		// write/read signal (1 for write)

	output wire [31:0] 	dbgreg_dout	// cpu register output (debugging demo)
);

	// IF
	wire				if_ce;

	// IF/ID -- ID
	wire[`InstAddrBus]	pc;
	wire[`InstAddrBus]	id_pc;
	wire[`InstBus]		id_inst;

	// ID -- Regfile
	wire[`RegBus]		rdata1;
	wire[`RegBus]		rdata2;
	wire				re1;
	wire[`RegAddrBus]	raddr1;
	wire				re2;
	wire[`RegAddrBus]	raddr2;

	// ID -- ID/EX
	wire[`AluSelBus]	id_alusel;
	wire[`AluOpBus]		id_aluop;
	wire[`RegBus]		id_opv1;
	wire[`RegBus]		id_opv2;
	wire[`RegAddrBus]	id_waddr;
	wire				id_we;

	// ID/EX -- EX
	wire[`AluSelBus]	ex_alusel;
	wire[`AluOpBus] 	ex_aluop;
	wire[`RegBus]		ex_opv1;
	wire[`RegBus]		ex_opv2;
	wire[`RegAddrBus]	ex_waddr_i;
	wire				ex_we_i;

	// EX -- EX/MEM
	wire[`RegAddrBus]	ex_waddr_o;
	wire				ex_we_o;
	wire[`RegBus]		ex_wdata;

	// EX/MEM -- MEM
	wire[`RegAddrBus]	mem_waddr_i;
	wire				mem_we_i;
	wire[`RegBus]		mem_wdata_i;

	// MEM -- MEM/WB
	wire[`RegAddrBus]	mem_waddr_o;
	wire				mem_we_o;
	wire[`RegBus]		mem_wdata_o;

	// MEM/WB -- WB
	wire[`RegAddrBus]	wb_waddr;
	wire				wb_we;
	wire[`RegBus]		wb_wdata;

	// pc_reg
	pc_reg pc_reg0 (
		.clk(clk_in),
		.rst(rst_in),
		.pc(pc),
		.ce(if_ce)
	);

	// read instruction
	assign mem_wr = 0;
	assign mem_a = pc;

	// IF/ID
	if_id if_id0 (
		.clk(clk_in),
		.rst(rst_in),
		.if_pc(pc),
		.if_inst(mem_dout),
		.id_pc(id_pc),
		.id_inst(id_inst)
	);

	// ID
	id id0 (
		.rst(rst_in),
		.pc(id_pc),
		.inst(id_inst),

		.rdata1(rdata1),
		.rdata2(rdata2),

		.re1(re1),
		.raddr1(raddr1),
		.re2(re2),
		.raddr2(raddr2),

		.alusel(id_alusel),
		.aluop(id_aluop),
		.we(id_we),
		.waddr(id_waddr),
		.opv1(id_opv1),
		.opv2(id_opv2)
	);

	// Regfile
	regfile regfile0 (
		.clk(clk_in),
		.rst(rst_in),

		.we(wb_we),
		.waddr(wb_waddr),
		.wdata(wb_wdata),

		.re1(re1),
		.raddr1(raddr1),
		.rdata1(rdata1),
		.re2(re2),
		.raddr2(raddr2),
		.rdata2(rdata2)
	);

	// ID/EX
	id_ex id_ex0 (
		.clk(clk_in),
		.rst(rst_in),

		.id_alusel(id_alusel),
		.id_aluop(id_aluop),
		.id_opv1(id_opv1),
		.id_opv2(id_opv2),
		.id_waddr(id_waddr),
		.id_we(id_we),

		.ex_alusel(ex_alusel),
		.ex_aluop(ex_aluop),
		.ex_opv1(ex_opv1),
		.ex_opv2(ex_opv2),
		.ex_waddr(ex_waddr_i),
		.ex_we(ex_we_i)
	);

	// EX
	ex ex0 (
		.rst(rst_in),
		.alusel(ex_alusel),
		.aluop(ex_aluop),
		.opv1(ex_opv1),
		.opv2(ex_opv2),
		.waddr_i(ex_waddr_i),
		.we_i(ex_we_i),

		.waddr_o(ex_waddr_o),
		.we_o(ex_we_o),
		.wdata(ex_wdata)
	);

	// EX/MEM
	ex_mem ex_mem0 (
		.clk(clk_in),
		.rst(rst_in),

		.ex_waddr(ex_waddr_o),
		.ex_we(ex_we_o),
		.ex_wdata(ex_wdata),

		.mem_waddr(mem_waddr_i),
		.mem_we(mem_we_i),
		.mem_wdata(mem_wdata_i)
	);

	// MEM
	mem mem0 (
		.rst(rst_in),

		.waddr_i(mem_waddr_i),
		.we_i(mem_we_i),
		.wdata_i(mem_wdata_i),

		.waddr_o(mem_waddr_o),
		.we_o(mem_we_o),
		.wdata_o(mem_wdata_o)
	);

	// MEM/WB
	mem_wb mem_wb0 (
		.clk(clk_in),
		.rst(rst_in),

		.mem_waddr(mem_waddr_o),
		.mem_we(mem_we_o),
		.mem_wdata(mem_wdata_o),

		.wb_waddr(wb_waddr),
		.wb_we(wb_we),
		.wb_wdata(wb_wdata)
	);

	// implementation goes here

	// Specifications:
	// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
	// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
	// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
	// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
	// - 0x30000 read: read a byte from input
	// - 0x30000 write: write a byte to output (write 0x00 is ignored)
	// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
	// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

	always @(posedge clk_in)
		begin
			if (rst_in)
			begin
		
			end
			else if (!rdy_in)
			begin
		
			end
			else
			begin
		
			end
		end

endmodule