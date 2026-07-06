`timescale 1ns/1ps

module decode (
    input clk,
    input reset_n,

    // from IF/ID pipeline registers
    input [31:0] instr_i,
    input [31:0] if_id_pc_i,
    input [31:0] if_id_pc4_i,

    // from write back (WB) stage
    input        wb_regWrite_i,
    input [4:0]  wb_rd_i,
    input [31:0] wb_wdata_i,

    // from execute (EX) stage, for hazard detection
    input        ex_memRead_i,
    input [4:0]  ex_rd_i,

    // from ID stage forwarding inputs
    input [31:0] ex_alu_result_i,
    input [4:0]  ex_rd_addr_i,
    input        ex_regWrite_i,
    
    input [31:0] mem_alu_result_i,
    input [4:0]  mem_rd_addr_i,
    input        mem_regWrite_i,
    input        mem_memRead_i, 

    // to ID/EX pipeline registers
    output [31:0] rs1_data_o,
    output [31:0] rs2_data_o,
    output [31:0] imm_o,
    output [4:0]  rs1_addr_o,
    output [4:0]  rs2_addr_o,
    output [4:0]  rd_addr_o,

    // control signals
    output        id_ALUSrc_o, 
    output        id_memToReg_o, 
    output        id_regWrite_o, 
    output        id_memRead_o, 
    output        id_memWrite_o, 
    output        id_branch_o, 
    output        id_jump_o, 
    output [1:0]  id_ALUOp_o,
    output [31:0] id_ex_pc_o,
    output [31:0] id_ex_pc4_o,

    output        stall_hazard_o,

    // outputs of ID stage branch
    output [31:0] target_pc_o,
    output        pc_src_o
);

    wire [4:0] rs1, rs2, rd;
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instr_i[6:0];
    assign rd     = instr_i[11:7];
    assign funct3 = instr_i[14:12];
    assign rs1    = instr_i[19:15];
    assign rs2    = instr_i[24:20];
    assign funct7 = instr_i[31:25];

    assign rs1_addr_o = rs1;
    assign rs2_addr_o = rs2;
    assign rd_addr_o  = rd;

    // control unit
    wire ctrl_ALUSrc, ctrl_memToReg, ctrl_memRead, ctrl_regWrite;
    wire ctrl_memWrite, ctrl_branch, ctrl_jump;
    wire [1:0] ctrl_ALUOp;

    control_unit ctrl (
        .opcode_i(opcode),
        .ALUSrc_o(ctrl_ALUSrc), 
        .memToReg_o(ctrl_memToReg), 
        .regWrite_o(ctrl_regWrite),
        .memRead_o(ctrl_memRead), 
        .memWrite_o(ctrl_memWrite), 
        .branch_o(ctrl_branch), 
        .jump_o(ctrl_jump),
        .ALUOp_o(ctrl_ALUOp)
    );

    
    wire id_is_branch_or_jump = ctrl_branch | ctrl_jump;

    wire load_use_ex = (ex_memRead_i == 1'b1) && ((ex_rd_i == rs1 && rs1 != 5'b0) || (ex_rd_i == rs2 && rs2 != 5'b0));

    wire load_use_mem_for_branch = id_is_branch_or_jump && (mem_memRead_i == 1'b1) && ((mem_rd_addr_i == rs1 && rs1 != 5'b0) || (mem_rd_addr_i == rs2 && rs2 != 5'b0));

    wire load_use_hazard = load_use_ex | load_use_mem_for_branch;
                            
    assign stall_hazard_o = load_use_hazard;

    // register file
    register_file regFile (
        .clk(clk),
        .rst_n(reset_n),
        .en_i(wb_regWrite_i), 
        .rs1_i(rs1), 
        .rs2_i(rs2),
        .rd_i(wb_rd_i), 
        .wdata_i(wb_wdata_i), 
        .rdata1_o(rs1_data_o), 
        .rdata2_o(rs2_data_o)
    );

    // immediate generator
    imm_gen immGen (
        .reset_n(reset_n),
        .instr_i(instr_i),
        .imm_o(imm_o)
    );

    // if stall so MUX for control signals
    assign id_ALUSrc_o   = load_use_hazard ? 1'b0  : ctrl_ALUSrc;
    assign id_memToReg_o = load_use_hazard ? 1'b0  : ctrl_memToReg;
    assign id_regWrite_o = load_use_hazard ? 1'b0  : ctrl_regWrite;
    assign id_memRead_o  = load_use_hazard ? 1'b0  : ctrl_memRead;
    assign id_memWrite_o = load_use_hazard ? 1'b0  : ctrl_memWrite;
    assign id_branch_o   = load_use_hazard ? 1'b0  : ctrl_branch;
    assign id_jump_o     = load_use_hazard ? 1'b0  : ctrl_jump;
    assign id_ALUOp_o    = load_use_hazard ? 2'b00 : ctrl_ALUOp;

    // passing the pipeline registers
    assign id_ex_pc_o = if_id_pc_i;
    assign id_ex_pc4_o = if_id_pc4_i;

    // forwarding MUXes for ID stage 
    wire [31:0] cmp_rs1 = (ex_regWrite_i && (ex_rd_addr_i != 0) && (ex_rd_addr_i == rs1)) ? ex_alu_result_i :
                          (mem_regWrite_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == rs1)) ? mem_alu_result_i :
                          rs1_data_o;

    wire [31:0] cmp_rs2 = (ex_regWrite_i && (ex_rd_addr_i != 0) && (ex_rd_addr_i == rs2)) ? ex_alu_result_i :
                          (mem_regWrite_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == rs2)) ? mem_alu_result_i :
                          rs2_data_o;

    // branch target adder
    wire is_jalr = (opcode == 7'b1100111);
    
    wire [31:0] branch_target = if_id_pc_i + imm_o;
    wire [31:0] jalr_target   = (cmp_rs1 + imm_o) & ~32'h00000001;
    
    assign target_pc_o = is_jalr ? jalr_target : branch_target;

    wire eq          = (cmp_rs1 == cmp_rs2);
    wire signed_lt   = ($signed(cmp_rs1) < $signed(cmp_rs2));
    wire unsigned_lt = (cmp_rs1 < cmp_rs2);

    wire is_beq  = (funct3 == 3'b000) & eq;
    wire is_bne  = (funct3 == 3'b001) & !eq;
    wire is_blt  = (funct3 == 3'b100) & signed_lt;
    wire is_bge  = (funct3 == 3'b101) & !signed_lt;
    wire is_bltu = (funct3 == 3'b110) & unsigned_lt;
    wire is_bgeu = (funct3 == 3'b111) & !unsigned_lt;

    wire branch_taken_id = ctrl_branch & (is_beq | is_bne | is_blt | is_bge | is_bltu | is_bgeu);

    // If there is a hazard, to wait for pipeline
    assign pc_src_o = load_use_hazard ? 1'b0 : (branch_taken_id | ctrl_jump);

endmodule