/*
	Instruction opcode
*/
`define OP_OP_IMM	7'b0010011

/*
  	Instruction funct3
*/

// OP_IMM
`define FUNCT3_ORI  3'b110

/*
  	Hardware Properties
*/

// Instruction Memory
`define InstAddrBus     31:0
`define InstBus         31:0
`define InstMemNum      131072
`define InstMemNumLog2  17

// Register File
`define RegAddrBus  4:0
`define RegBus      31:0
`define RegNum      32
`define RegNumLog2  5

// ALU
`define AluSelBus	7:0
`define AluOpBus	2:0

`endif