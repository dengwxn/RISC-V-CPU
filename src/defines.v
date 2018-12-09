`ifndef DEFINES_V
`define DEFINES_V

/*
	Instruction opcode
*/
`define OP_OP_IMM	7'b0010011
`define OP_OP		7'b0110011
`define OP_LUI		7'b0110111
`define OP_AUIPC	7'b0010111

/*
  	Instruction funct3
*/

// OP_IMM
`define FUNCT3_ADDI			3'b000
`define FUNCT3_SLLI			3'b001
`define FUNCT3_SLTI			3'b010
`define FUNCT3_SLTIU		3'b011
`define FUNCT3_XORI			3'b100
`define FUNCT3_SRLI_SRAI	3'b101
`define FUNCT3_ORI  		3'b110
`define FUNCT3_ANDI 		3'b111

// OP
`define FUNCT3_ADD_SUB	3'b000
`define FUNCT3_SLL		3'b001
`define FUNCT3_SLT		3'b010
`define FUNCT3_SLTU		3'b011
`define FUNCT3_XOR 		3'b100
`define FUNCT3_SRL_SRA	3'b101
`define FUNCT3_OR  		3'b110
`define FUNCT3_AND  	3'b111

/*
	Instruction funct7
*/

// ADD_SUB
`define FUNCT7_ADD		7'b0000000
`define FUNCT7_SUB		7'b0100000

// SRLI_SRAI
`define FUNCT7_SRLI		7'b0000000
`define FUNCT7_SRAI		7'b0100000

// SRL_SRA
`define FUNCT7_SRL		7'b0000000
`define FUNCT7_SRA		7'b0100000

/*
	AluSel
*/
`define EXE_RES_NOP		0
`define EXE_RES_LOGIC	1
`define EXE_RES_ARITH	2
`define EXE_RES_SHIFT	3

/*
	AluOp
*/
`define EXE_NOP_OP		0
`define EXE_OR_OP		1
`define EXE_XOR_OP		2
`define EXE_AND_OP		3

`define EXE_ADD_OP		4
`define EXE_SUB_OP		5

`define EXE_SLT_OP		6
`define EXE_SLTU_OP		7

`define EXE_SLL_OP		8
`define EXE_SRL_OP		9
`define EXE_SRA_OP		10

/*
  	Hardware Properties
*/

// Memory
`define MemAddrBus		31:0
`define MemBus			7:0

// Instruction Memory
`define InstAddrBus     31:0
`define InstBus         31:0
`define InstMemNum      131072
`define InstMemNumLog2  17

// Data Memory
`define DataAddrBus     31:0
`define DataBus         31:0
`define DataMemNum      131072
`define DataMemNumLog2  17

// Register File
`define RegAddrBus  4:0
`define RegBus      31:0
`define RegNum      32
`define RegNumLog2  5

// ALU
`define AluSelBus	7:0
`define AluOpBus	2:0

`endif