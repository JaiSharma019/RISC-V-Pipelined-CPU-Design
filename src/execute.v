`timescale 1ns/1ps

module execute (
    // from ID/EX pipeline registers
    input [31:0] id_ex_pc_i,
    input [31:0] id_ex_rs1_data_i,
    input [31:0] id_ex_rs2_data_i,
    input [31:0] id_ex_imm_i,
    input [4:0]  id_ex_rs1_addr_i,
    input [4:0]  id_ex_rs2_addr_i,
    input [4:0]  id_ex_rd_addr_i,
    input [2:0]  id_ex_funct3_i,
    input        id_ex_funct7_30_i,
    input [6:0]  id_ex_opcode_i,

    input [31:0] id_ex_pc4_i,
    input        id_ex_memRead_i,
    input        id_ex_memWrite_i,
    input        id_ex_regWrite_i,
    input        id_ex_memToReg_i,

    // control signals from ID
    input [1:0]  id_ex_ALUOp_i,
    input        id_ex_ALUSrc_i,
    input        id_ex_jump_i,

    // for hazard bypass
    input [4:0]  ex_mem_rd_addr_i,
    input        ex_mem_regWrite_i,
    input [31:0] ex_mem_alu_result_i, // 1 step ahead

    input [4:0]  mem_wb_rd_addr_i,
    input        mem_wb_regWrite_i,
    input [31:0] mem_wb_wdata_i,      // 2 step ahead

    // to EX/MEM pipeline registers
    output [31:0] ex_mem_alu_result_o,
    output [31:0] ex_mem_rs2_data_o,  
    output [4:0]  ex_mem_rd_addr_o,
    // output [31:0] target_pc_o,        // output for branching (fetch)
    // output        pc_src_o,           // The trigger to flush and jump
    output        ex_mem_memRead_o,
    output        ex_mem_memWrite_o,
    output        ex_mem_regWrite_o,
    output        ex_mem_memToReg_o
);

    // forwarding unit for hazard bypassing
    wire [1:0] forwardA;
    wire [1:0] forwardB;

    forwarding_unit fwd(
    .rs1_addr_i(id_ex_rs1_addr_i),
    .rs2_addr_i(id_ex_rs2_addr_i),
    .ex_mem_rd_i(ex_mem_rd_addr_i),
    .ex_mem_regWrite_i(ex_mem_regWrite_i),
    .mem_wb_rd_i(mem_wb_rd_addr_i),
    .mem_wb_regWrite_i(mem_wb_regWrite_i),

    .forwardA_o(forwardA),
    .forwardB_o(forwardB)

);

    // forwarding MUXes
    reg [31:0] A_fwd;
    reg [31:0] B_fwd;

    always@(*) begin 
        case(forwardA) // 3 to 1 MUX for A
            2'b00: A_fwd = id_ex_rs1_data_i;    // no hazard
            2'b10: A_fwd = ex_mem_alu_result_i; // EX hazard bypass
            2'b01: A_fwd = mem_wb_wdata_i;      // MEM hazard bypass
            default: A_fwd = id_ex_rs1_data_i;
        endcase
    end

    always@(*) begin 
        case(forwardB) // 3 to 1 MUX for B
            2'b00: B_fwd = id_ex_rs2_data_i;    // no hazard
            2'b10: B_fwd = ex_mem_alu_result_i; // EX hazard bypass
            2'b01: B_fwd = mem_wb_wdata_i;      // MEM hazard bypass
            default: B_fwd = id_ex_rs2_data_i;
        endcase
    end

    assign ex_mem_rs2_data_o = B_fwd; // for STORE instructions to get right data

    // ALUSrc MUX for LUI and AUIPC
    wire [31:0] alu_in1;
    wire [31:0] alu_in2;

    wire is_auipc = (id_ex_opcode_i == 7'b0010111);
    wire is_lui = (id_ex_opcode_i == 7'b0110111);

    assign alu_in1 = is_auipc ? id_ex_pc_i : (is_lui ? 32'b0 : A_fwd); // for AUIPC & LUI
    assign alu_in2 = id_ex_ALUSrc_i ? id_ex_imm_i : B_fwd; // for ALUSrc

    // for ALU
    wire [3:0] ctrl;
    wire       zero_flag;

    // only pass bit 30 to the ALU if it's an R-Type math instruction or an I-Type Shift instruction
    wire alu_funct7 = (id_ex_opcode_i == 7'b0110011 || (id_ex_opcode_i == 7'b0010011 && id_ex_funct3_i == 3'b101)) ? id_ex_funct7_30_i : 1'b0;

    alu_control aluCtrl (
    .ALUOp_i(id_ex_ALUOp_i),
    .funct3_i(id_ex_funct3_i),
    .funct7_30_i(alu_funct7),
    .alu_ctrl_o(ctrl)
);

    wire [31:0] alu_math_result;

    alu ALU (
    .a_i(alu_in1),
    .b_i(alu_in2),
    .ctrl_i(ctrl),
    .out_o(alu_math_result),
    .zero_o(zero_flag)
);

    assign ex_mem_alu_result_o = id_ex_jump_i ? id_ex_pc4_i : alu_math_result;

    // pass through
    assign ex_mem_rd_addr_o  = id_ex_rd_addr_i;
    assign ex_mem_memRead_o  = id_ex_memRead_i;
    assign ex_mem_memWrite_o = id_ex_memWrite_i;
    assign ex_mem_regWrite_o = id_ex_regWrite_i;
    assign ex_mem_memToReg_o = id_ex_memToReg_i; 
    
endmodule