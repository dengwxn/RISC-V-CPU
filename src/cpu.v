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

	// PC -- IF
	wire[`InstAddrBus]	if_pc_i;
	wire				if_ce;

	// IF -- IF/ID
	wire[`InstAddrBus]	if_pc_o;
	wire[`InstBus]		if_inst;

	// IF/ID -- ID
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
	wire[`InstAddrBus]	id_link_addr;
	wire[`RegBus]		id_mem_offset;

	// ID -- * (BR)
	wire				br;
	wire[`InstAddrBus]	br_addr;

	// ID/EX -- EX
	wire[`AluSelBus]	ex_alusel;
	wire[`AluOpBus] 	ex_aluop;
	wire[`RegBus]		ex_opv1;
	wire[`RegBus]		ex_opv2;
	wire[`RegAddrBus]	ex_waddr_i;
	wire				ex_we_i;
	wire[`InstAddrBus]	ex_link_addr_i;
	wire[`RegBus]		ex_mem_offset_i;

	// EX -- EX/MEM
	wire[`RegAddrBus]	ex_waddr_o;
	wire				ex_we_o;
	wire[`RegBus]		ex_wdata;
	wire[`DataAddrBus]	ex_mem_addr;
	wire[`AluOpBus]		ex_mem_aluop;
	wire[`RegBus]		ex_rt_data;

	// EX/MEM -- MEM
	wire[`RegAddrBus]	mem_waddr_i;
	wire				mem_we_i;
	wire[`RegBus]		mem_wdata_i;
	wire[`DataAddrBus]	mem_mem_addr_i;
	wire[`AluOpBus]		mem_mem_aluop_i;
	wire[`RegBus]		mem_rt_data_i;

	// MEM -- MEM/WB
	wire[`RegAddrBus]	mem_waddr_o;
	wire				mem_we_o;
	wire[`RegBus]		mem_wdata_o;

	// MEM/WB -- WB
	wire[`RegAddrBus]	wb_waddr;
	wire				wb_we;
	wire[`RegBus]		wb_wdata;

	// STALL
	wire[4 : 0]			stall;
	wire				if_stallreq;
	wire				mem_stallreq;

	// * -- MEM_CTRL
	wire[`InstAddrBus]	if_raddr;
	wire				if_cancel;
	wire[`DataAddrBus]	mem_mem_addr_o;
	wire[`AluOpBus]		mem_mem_aluop_o;
	wire[`RegBus]		mem_rt_data_o;

	// MEM_CTRL -- *
	wire[`InstBus]	mem_ctrl_if_rdata_o; 
	wire[`DataBus]	mem_ctrl_load_store_rdata_o; 
	wire				if_mem_ctrl_done;
	wire				load_store_mem_ctrl_done;

	// mem_ctrl
	mem_ctrl mem_ctrl0(
		.clk(clk_in),
		.rst(rst_in),

		.if_raddr(if_raddr),
		.if_rdata_o(mem_ctrl_if_rdata_o),
		.if_mem_ctrl_done(if_mem_ctrl_done),

		.mem_ctrl_wr(mem_wr),
		.addr(mem_a),
		.wdata(mem_dout),
		.rdata(mem_din),

		.if_cancel(if_cancel),

		.mem_addr(mem_mem_addr_o),
		.mem_aluop(mem_mem_aluop_o),
		.rt_data(mem_rt_data_o),
		.load_store_mem_ctrl_done(load_store_mem_ctrl_done),
		.load_store_rdata_o(mem_ctrl_load_store_rdata_o),

		.if_request(if_stallreq),
		.load_store_request(mem_stallreq)
	);

	// stall
	ctrl ctrl0 (
		.rst(rst_in),
		.if_stallreq(if_stallreq),
		.mem_stallreq(mem_stallreq),
		.stall(stall)
	);

	// pc_reg
	pc_reg pc_reg0 (
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),

		.pc(if_pc_i),
		.ce(if_ce),

		.br(br),
		.br_addr(br_addr),

		.rdy(rdy_in)
	);

	// if
	stage_if if0 (
		.clk(clk_in),
		.rst(rst_in),

		.pc_i(if_pc_i),
		.ce(if_ce),

		.pc_o(if_pc_o),
		.inst(if_inst),
		.if_stallreq(if_stallreq),

		.raddr(if_raddr),
		.if_mem_ctrl_done(if_mem_ctrl_done),
		.rdata(mem_ctrl_if_rdata_o),

		.br(br),
		.cancel(if_cancel)
	);

	// IF/ID
	if_id if_id0 (
		.clk(clk_in),
		.rst(rst_in),

		.if_pc(if_pc_o),
		.if_inst(if_inst),

		.id_pc(id_pc),
		.id_inst(id_inst),

		.br(br),

		.stall(stall)
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
		.opv2(id_opv2),

		.ex_we(ex_we_o),
		.ex_waddr(ex_waddr_o),
		.ex_wdata(ex_wdata),

		.mem_we(mem_we_o),
		.mem_waddr(mem_waddr_o),
		.mem_wdata(mem_wdata_o),

		.br(br),
		.br_addr(br_addr),
		.link_addr(id_link_addr),
		.mem_offset(id_mem_offset)
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
		.id_link_addr(id_link_addr),
		.id_mem_offset(id_mem_offset),

		.ex_alusel(ex_alusel),
		.ex_aluop(ex_aluop),
		.ex_opv1(ex_opv1),
		.ex_opv2(ex_opv2),
		.ex_waddr(ex_waddr_i),
		.ex_we(ex_we_i),
		.ex_link_addr(ex_link_addr_i),
		.ex_mem_offset(ex_mem_offset_i),

		.stall(stall)
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
		.wdata(ex_wdata),

		.link_addr(ex_link_addr_i),
		.mem_offset(ex_mem_offset_i),

		.mem_addr(ex_mem_addr),
		.mem_aluop(ex_mem_aluop),
		.rt_data(ex_rt_data)
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
		.mem_wdata(mem_wdata_i),

		.ex_mem_addr(ex_mem_addr),
		.ex_mem_aluop(ex_mem_aluop),
		.ex_rt_data(ex_rt_data),

		.mem_mem_addr(mem_mem_addr_i),
		.mem_mem_aluop(mem_mem_aluop_i),
		.mem_rt_data(mem_rt_data_i),

		.stall(stall)
	);

	// MEM
	mem mem0 (
		.rst(rst_in),

		.waddr_i(mem_waddr_i),
		.we_i(mem_we_i),
		.wdata_i(mem_wdata_i),

		.waddr_o(mem_waddr_o),
		.we_o(mem_we_o),
		.wdata_o(mem_wdata_o),

		.mem_addr_i(mem_mem_addr_i),
		.mem_aluop_i(mem_mem_aluop_i),
		.rt_data_i(mem_rt_data_i),

		.mem_stallreq(mem_stallreq),

		.mem_addr_o(mem_mem_addr_o),
		.mem_aluop_o(mem_mem_aluop_o),
		.rt_data_o(mem_rt_data_o),
		.load_store_mem_ctrl_done(load_store_mem_ctrl_done),
		.rdata(mem_ctrl_load_store_rdata_o)
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
		.wb_wdata(wb_wdata),

		.stall(stall)
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

	always @(posedge clk_in) begin
		if (rst_in) begin 
		end
		else if (!rdy_in) begin
		end
		else begin 
		end
	end

endmodule