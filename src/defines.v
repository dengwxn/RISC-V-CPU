`ifndef DEFINES_V
`define DEFINES_V

/*
	Instruction opcode
*/
`define OP_OP_IMM	7'b0010011
`define OP_OP		7'b0110011
`define OP_LUI		7'b0110111
`define OP_AUIPC	7'b0010111
`define OP_JAL		7'b1101111
`define OP_JALR		7'b1100111 
`define OP_BRANCH	7'b1100011
`define OP_LOAD		7'b0000011
`define OP_STORE	7'b0100011

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

// BRANCH
`define FUNCT3_BEQ		3'b000
`define FUNCT3_BNE		3'b001
`define FUNCT3_BLT		3'b100
`define FUNCT3_BGE		3'b101
`define FUNCT3_BLTU		3'b110
`define FUNCT3_BGEU		3'b111

// LOAD
`define FUNCT3_LB		3'b000
`define FUNCT3_LH		3'b001
`define FUNCT3_LW		3'b010
`define FUNCT3_LBU		3'b100
`define FUNCT3_LHU		3'b101

// STORE
`define FUNCT3_SB		3'b000
`define FUNCT3_SH		3'b001
`define FUNCT3_SW		3'b010

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
`define EXE_RES_NOP			0
`define EXE_RES_LOGIC		1
`define EXE_RES_ARITH		2
`define EXE_RES_SHIFT		3
`define EXE_RES_BRANCH		4
`define EXE_RES_LOAD_STORE	5

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

`define EXE_JAL_OP		11
`define EXE_JALR_OP		12

`define EXE_BEQ_OP		13
`define EXE_BNE_OP		14
`define EXE_BLT_OP		15	
`define EXE_BGE_OP		16
`define EXE_BLTU_OP		17
`define EXE_BGEU_OP		18

`define EXE_LB_OP 		19
`define EXE_LH_OP 		20
`define EXE_LW_OP 		21
`define EXE_LBU_OP 		22
`define EXE_LHU_OP 		23

`define EXE_SB_OP 		24
`define EXE_SH_OP 		25
`define EXE_SW_OP 		26

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
`define AluSelBus	2:0
`define AluOpBus	4:0

// MEMORY CONTROLLER
`define INIT_STATUS			6'b000000
`define IF_INIT_STATUS 		6'b000001
`define LOAD_INIT_STATUS 	6'b100001
`define STORE_INIT_STATUS 	6'b110001
`define RELEASE_STATUS 		6'b111111

`define START_REDIRECT				0
`define IF_DONE_REDIRECT			1
`define LOAD_STORE_DONE_REDIRECT	2
`define BOTH_DONE_REDIRECT			3

`define READ_STATUS_1		  4'b0001
`define READ_STATUS_2		  4'b0010
`define READ_STATUS_3		  4'b0011
`define READ_STATUS_4		  4'b0100
`define READ_STATUS_5		  4'b0101
`define READ_STATUS_6		  4'b0110
`define READ_STATUS_7		  4'b0111
`define READ_STATUS_8		  4'b1000
`define READ_STATUS_9		  4'b1001

`define WRITE_STATUS_1		  4'b0001
`define WRITE_STATUS_2		  4'b0010
`define WRITE_STATUS_3		  4'b0011
`define WRITE_STATUS_4		  4'b0100
`define WRITE_STATUS_5		  4'b0101
`define WRITE_STATUS_6		  4'b0110
`define WRITE_STATUS_7		  4'b0111
`define WRITE_STATUS_8		  4'b1000

`define WRITE_STATUS_1		  4'b0001
`define WRITE_STATUS_2		  4'b0010

`endif