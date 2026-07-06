`timescale 1ns/1ps

module core (
    input clk,
    input reset_n
);

    // Interconnecting Wires

    // IF out
    wire [31:0] if_pc_out, if_pc4_out, if_instr_out;
    
    // ID out 
    wire [31:0] id_rs1_data_out, id_rs2_data_out, id_imm_out, id_pc_out, id_pc4_out;
    wire [4:0]  id_rs1_addr_out, id_rs2_addr_out, id_rd_addr_out;
    wire        id_ALUSrc_out, id_memToReg_out, id_regWrite_out, id_memRead_out;
    wire        id_memWrite_out, id_branch_out, id_jump_out, stall_hazard;
    wire [1:0]  id_ALUOp_out;
    
    // EX out
    wire [31:0] ex_alu_result_out, ex_rs2_data_out, target_pc;
    wire [4:0]  ex_rd_addr_out;
    wire        pc_src; // The flush trigger
    wire        ex_memRead_out, ex_memWrite_out, ex_regWrite_out, ex_memToReg_out;
    
    // MEM out
    wire [31:0] mem_read_data_out, mem_alu_result_out;
    wire [4:0]  mem_rd_addr_out;
    wire        mem_regWrite_out, mem_memToReg_out;
    
    // WB out
    wire [31:0] wb_wdata_out;
    wire [4:0]  wb_rd_addr_out;
    wire        wb_regWrite_out;

    // Pipeline Registers

    // IF/ID register
    reg [31:0] if_id_pc, if_id_pc4, if_id_instr;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n || pc_src) begin 
            // Flush on reset OR if a branch is taken
            if_id_pc   <= 32'b0;
            if_id_pc4  <= 32'b0;
            if_id_instr <= 32'h00000013; // NOP instruction (addi x0, x0, 0)
        end else if (!stall_hazard) begin
            // Normal operation (freeze if stall_hazard is 1)
            if_id_pc   <= if_pc_out;
            if_id_pc4  <= if_pc4_out;
            if_id_instr <= if_instr_out;
        end
    end

    // ID/EX register
    reg [31:0] id_ex_pc, id_ex_pc4, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    reg [4:0]  id_ex_rs1_addr, id_ex_rs2_addr, id_ex_rd_addr;
    reg [2:0]  id_ex_funct3;
    reg        id_ex_funct7_30;
    reg [6:0]  id_ex_opcode;
    
    reg        id_ex_ALUSrc, id_ex_memToReg, id_ex_regWrite, id_ex_memRead;
    reg        id_ex_memWrite, id_ex_branch, id_ex_jump;
    reg [1:0]  id_ex_ALUOp;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n || stall_hazard) begin // || pc_src
            // Flush if branch taken OR if stall hazard detected (inject bubble)
            id_ex_pc        <= 32'b0;
            id_ex_pc4       <= 32'b0;
            id_ex_rs1_data  <= 32'b0;
            id_ex_rs2_data  <= 32'b0;
            id_ex_imm       <= 32'b0;
            id_ex_rs1_addr  <= 5'b0;
            id_ex_rs2_addr  <= 5'b0;
            id_ex_rd_addr   <= 5'b0;
            id_ex_funct3    <= 3'b0;
            id_ex_funct7_30 <= 1'b0;
            id_ex_opcode    <= 7'b0;
            
            // Clear control signals to prevent accidental writes
            id_ex_ALUSrc   <= 0; id_ex_memToReg <= 0; id_ex_regWrite <= 0;
            id_ex_memRead  <= 0; id_ex_memWrite <= 0; id_ex_branch   <= 0;
            id_ex_jump     <= 0; id_ex_ALUOp    <= 2'b0;
        end else begin
            id_ex_pc        <= id_pc_out;
            id_ex_pc4       <= id_pc4_out;
            id_ex_rs1_data  <= id_rs1_data_out;
            id_ex_rs2_data  <= id_rs2_data_out;
            id_ex_imm       <= id_imm_out;
            id_ex_rs1_addr  <= id_rs1_addr_out;
            id_ex_rs2_addr  <= id_rs2_addr_out;
            id_ex_rd_addr   <= id_rd_addr_out;
            id_ex_funct3    <= if_id_instr[14:12]; // Extracted directly from instruction
            id_ex_funct7_30 <= if_id_instr[30];
            id_ex_opcode    <= if_id_instr[6:0];
            
            id_ex_ALUSrc    <= id_ALUSrc_out;
            id_ex_memToReg  <= id_memToReg_out;
            id_ex_regWrite  <= id_regWrite_out;
            id_ex_memRead   <= id_memRead_out;
            id_ex_memWrite  <= id_memWrite_out;
            id_ex_branch    <= id_branch_out;
            id_ex_jump      <= id_jump_out;
            id_ex_ALUOp     <= id_ALUOp_out;
        end
    end

    // EX/MEM register
    reg [31:0] ex_mem_alu_result, ex_mem_rs2_data;
    reg [4:0]  ex_mem_rd_addr;
    reg [2:0]  ex_mem_funct3;
    reg        ex_mem_memRead, ex_mem_memWrite, ex_mem_regWrite, ex_mem_memToReg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ex_mem_alu_result <= 32'b0;
            ex_mem_rs2_data   <= 32'b0;
            ex_mem_rd_addr    <= 5'b0;
            ex_mem_funct3     <= 3'b0;
            ex_mem_memRead    <= 0; ex_mem_memWrite <= 0;
            ex_mem_regWrite   <= 0; ex_mem_memToReg <= 0;
        end else begin
            ex_mem_alu_result <= ex_alu_result_out;
            ex_mem_rs2_data   <= ex_rs2_data_out;
            ex_mem_rd_addr    <= ex_rd_addr_out;
            ex_mem_funct3     <= id_ex_funct3; // Pass along for MEM byte addressing
            ex_mem_memRead    <= ex_memRead_out;
            ex_mem_memWrite   <= ex_memWrite_out;
            ex_mem_regWrite   <= ex_regWrite_out;
            ex_mem_memToReg   <= ex_memToReg_out;
        end
    end

    // MEM/WB register
    reg [31:0] mem_wb_read_data, mem_wb_alu_result;
    reg [4:0]  mem_wb_rd_addr;
    reg        mem_wb_regWrite, mem_wb_memToReg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            mem_wb_read_data  <= 32'b0;
            mem_wb_alu_result <= 32'b0;
            mem_wb_rd_addr    <= 5'b0;
            mem_wb_regWrite   <= 0; mem_wb_memToReg <= 0;
        end else begin
            mem_wb_read_data  <= mem_read_data_out;
            mem_wb_alu_result <= mem_alu_result_out;
            mem_wb_rd_addr    <= mem_rd_addr_out;
            mem_wb_regWrite   <= mem_regWrite_out;
            mem_wb_memToReg   <= mem_memToReg_out;
        end
    end

    // Module Instantiations

    // Instruction Fetch (IF) stage
    fetch IF (
    .clk(clk),
    .areset_n(reset_n),

    .pc_stall_i(stall_hazard), // freezes PC when high
    .pc_src_i(pc_src), // jump or branch when high
    .pc_branch_i(target_pc), // address to jump

    // to IF/ID pipeline registers
    .pc_o(if_pc_out), 
    .pc4_o(if_pc4_out),
    .instr_o(if_instr_out)
);

    // Instruction Decode (ID) stage
    decode ID (
    .clk(clk),
    .reset_n(reset_n),

    // from IF/ID pipeline registers
    .instr_i(if_id_instr),
    .if_id_pc_i(if_id_pc),
    .if_id_pc4_i(if_id_pc4),

    // from write back (WB) stage
    .wb_regWrite_i(wb_regWrite_out),
    .wb_rd_i(wb_rd_addr_out),
    .wb_wdata_i(wb_wdata_out),

    // from execute (EX) stage, for hazard detection
    .ex_memRead_i(id_ex_memRead),
    .ex_rd_i(id_ex_rd_addr),

    
    .ex_alu_result_i(ex_alu_result_out), 
    .ex_rd_addr_i(ex_rd_addr_out),     
    .ex_regWrite_i(ex_regWrite_out),

    .mem_alu_result_i(mem_alu_result_out), 
    .mem_rd_addr_i(mem_rd_addr_out),
    .mem_regWrite_i(mem_regWrite_out),
    
    .mem_memRead_i(ex_mem_memRead),
    
    // to ID/EX pipeline registers
    .rs1_data_o(id_rs1_data_out),
    .rs2_data_o(id_rs2_data_out),
    .imm_o(id_imm_out),
    .rs1_addr_o(id_rs1_addr_out),
    .rs2_addr_o(id_rs2_addr_out),
    .rd_addr_o(id_rd_addr_out),

    // control signals
    .id_ALUSrc_o(id_ALUSrc_out), 
    .id_memToReg_o(id_memToReg_out), 
    .id_regWrite_o(id_regWrite_out), 
    .id_memRead_o(id_memRead_out), 
    .id_memWrite_o(id_memWrite_out), 
    .id_branch_o(id_branch_out), 
    .id_jump_o(id_jump_out), 
    .id_ALUOp_o(id_ALUOp_out),
    .id_ex_pc_o(id_pc_out),
    .id_ex_pc4_o(id_pc4_out),

    .stall_hazard_o(stall_hazard),

    
    .target_pc_o(target_pc), // The address to jump to
    .pc_src_o(pc_src)     // The trigger to flush and jump
);

    // Execute (EX) stage
    execute EX (
    // from ID/EX pipeline registers
    .id_ex_pc_i(id_ex_pc),
    .id_ex_rs1_data_i(id_ex_rs1_data),
    .id_ex_rs2_data_i(id_ex_rs2_data),
    .id_ex_imm_i(id_ex_imm),
    .id_ex_rs1_addr_i(id_ex_rs1_addr),
    .id_ex_rs2_addr_i(id_ex_rs2_addr),
    .id_ex_rd_addr_i(id_ex_rd_addr),
    .id_ex_funct3_i(id_ex_funct3),
    .id_ex_funct7_30_i(id_ex_funct7_30),
    .id_ex_opcode_i(id_ex_opcode),

    .id_ex_pc4_i(id_ex_pc4),
    .id_ex_memRead_i(id_ex_memRead),
    .id_ex_memWrite_i(id_ex_memWrite),
    .id_ex_regWrite_i(id_ex_regWrite),
    .id_ex_memToReg_i(id_ex_memToReg),

    // control signals from ID
    .id_ex_ALUOp_i(id_ex_ALUOp),
    .id_ex_ALUSrc_i(id_ex_ALUSrc),

    .id_ex_jump_i(id_ex_jump),

    // for hazard bypass
    .ex_mem_rd_addr_i(ex_mem_rd_addr),
    .ex_mem_regWrite_i(ex_mem_regWrite),
    .ex_mem_alu_result_i(ex_mem_alu_result), // 1 step ahead

    .mem_wb_rd_addr_i(mem_wb_rd_addr),
    .mem_wb_regWrite_i(mem_wb_regWrite),
    .mem_wb_wdata_i(wb_wdata_out),      // 2 step ahead

    // to EX/MEM pipeline registers
    .ex_mem_alu_result_o(ex_alu_result_out),
    .ex_mem_rs2_data_o(ex_rs2_data_out),  
    .ex_mem_rd_addr_o(ex_rd_addr_out),
    
    .ex_mem_memRead_o(ex_memRead_out),
    .ex_mem_memWrite_o(ex_memWrite_out),
    .ex_mem_regWrite_o(ex_regWrite_out),
    .ex_mem_memToReg_o(ex_memToReg_out)
);

    // Memory (MEM) stage
    memory MEM (
    .clk(clk),
    .reset_n(reset_n),

    // from EX/MEM pipeline registers
    .ex_mem_alu_result_i(ex_mem_alu_result), // memory address or arithmentic answer
    .ex_mem_rs2_data_i(ex_mem_rs2_data),   // data to store
    .ex_mem_rd_addr_i(ex_mem_rd_addr),
    .ex_mem_funct3_i(ex_mem_funct3),

    // control signals
    .ex_mem_memRead_i(ex_mem_memRead),
    .ex_mem_memWrite_i(ex_mem_memWrite),
    .ex_mem_regWrite_i(ex_mem_regWrite),
    .ex_mem_memToReg_i(ex_mem_memToReg),

    // to MEM/WB pipeline registers
    .mem_wb_read_data_o(mem_read_data_out),  // data loaded
    .mem_wb_alu_result_o(mem_alu_result_out), // arithmetic answer passed
    .mem_wb_rd_addr_o(mem_rd_addr_out),

    // out control signals
    .mem_wb_regWrite_o(mem_regWrite_out),
    .mem_wb_memToReg_o(mem_memToReg_out)
);

    // Write Back (WB) stage    
    write_back WB (
    // from MEM/WB pipeline registers
    .mem_wb_alu_result_i(mem_wb_alu_result),
    .mem_wb_read_data_i(mem_wb_read_data),
    .mem_wb_rd_addr_i(mem_wb_rd_addr),

    // control signals
    .mem_wb_regWrite_i(mem_wb_regWrite),
    .mem_wb_memToReg_i(mem_wb_memToReg),   

    // to decode stage
    .wb_wdata_o(wb_wdata_out),        // final data to be written to register file
    .wb_rd_addr_o(wb_rd_addr_out),      // address to be written in there
    .wb_regWrite_o(wb_regWrite_out)      // enable to write
);

endmodule