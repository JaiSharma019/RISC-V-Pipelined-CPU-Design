`timescale 1ns/1ps

module forwarding_unit (
    // from current stage
    input [4:0] rs1_addr_i,
    input [4:0] rs2_addr_i,

    // from 1 instruction ahead (EX/MEM)
    input [4:0] ex_mem_rd_i,
    input ex_mem_regWrite_i,

    // from 2 instructions ahead (MEM/WB)
    input [4:0] mem_wb_rd_i,
    input mem_wb_regWrite_i,

    // MUX control signals
    output reg [1:0] forwardA_o,
    output reg [1:0] forwardB_o

);

    always@(*) begin 
        // for A (checking rs1)
        forwardA_o = 2'b00; // for no hazard, default
        // if EX hazard (1st priority)
        if (ex_mem_regWrite_i && (ex_mem_rd_i != 5'b0) && (ex_mem_rd_i == rs1_addr_i)) begin
            forwardA_o = 2'b10; 
        end
        // if MEM hazard (2nd priority)
        else if (mem_wb_regWrite_i && (mem_wb_rd_i != 5'b0) && (mem_wb_rd_i == rs1_addr_i)) begin
            forwardA_o = 2'b01; 
        end

        // for B (checking rs2)
        forwardB_o = 2'b00; // for no hazard, default
        // if EX hazard (1st priority)
        if (ex_mem_regWrite_i && (ex_mem_rd_i != 5'b0) && (ex_mem_rd_i == rs2_addr_i)) begin
            forwardB_o = 2'b10; 
        end
        // if MEM hazard (2nd priority)
        else if (mem_wb_regWrite_i && (mem_wb_rd_i != 5'b0) && (mem_wb_rd_i == rs2_addr_i)) begin
            forwardB_o = 2'b01; 
        end

    end
    
endmodule