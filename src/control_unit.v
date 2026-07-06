`timescale 1ns/1ps

module control_unit (
    input [6:0] opcode_i,
    output reg ALUSrc_o, // set if load, store, I-type math
    output reg memToReg_o, // set if regWrite and data comes from memory
    output reg regWrite_o, // set if computes value, loads data or links jump (instr having rd)
    output reg memRead_o, // set if load (instruction interfacing memory)
    output reg memWrite_o, // set if store (instruction interfacing memory)
    output reg branch_o, // set if conditional branch
    output reg jump_o, // set if JAL/JALR to flush pipeline
    output reg [1:0] ALUOp_o // 00 -> load/store, 01 -> branches, 10 -> math instr (looks to func)
);

    always@(*) begin 
        case(opcode_i) 
            7'b0110011: begin // R-type
                ALUSrc_o = 1'b0;
                memToReg_o = 1'b0;
                regWrite_o = 1'b1;
                memRead_o = 1'b0;
                memWrite_o = 1'b0;
                branch_o = 1'b0;
                jump_o = 1'b0;
                ALUOp_o = 2'b10;
            end
            7'b0000011: begin // I-type : load
                ALUSrc_o = 1'b1;
                memRead_o = 1'b1;
                memWrite_o = 1'b0;
                memToReg_o = 1'b1;
                regWrite_o = 1'b1;
                branch_o = 1'b0;
                jump_o = 1'b0;
                ALUOp_o = 2'b00; // force add
            end
            7'b0010011: begin // I-type : ADDI, SLLI
                ALUSrc_o = 1'b1;
                memToReg_o = 1'b0;
                regWrite_o = 1'b1;
                memRead_o = 1'b0;
                memWrite_o = 1'b0;
                branch_o = 1'b0;
                jump_o = 1'b0;
                ALUOp_o = 2'b10;
            end
            7'b0100011: begin // S-type : store
                ALUSrc_o = 1'b1;
                memToReg_o = 1'b0;
                regWrite_o = 1'b0;
                memRead_o = 1'b0;
                memWrite_o = 1'b1;
                branch_o = 1'b0;
                jump_o = 1'b0;
                ALUOp_o = 2'b00;
            end
            7'b1100011: begin // B-type : BEQ, BNE
                ALUSrc_o = 1'b0;
                memToReg_o = 1'b0;
                regWrite_o = 1'b0;
                memRead_o = 1'b0;
                memWrite_o = 1'b0;
                branch_o = 1'b1;
                jump_o = 1'b0;
                ALUOp_o = 2'b01;
            end
            7'b0110111: begin // U-type : LUI
                ALUSrc_o = 1'b1;
                memToReg_o = 1'b0;
                regWrite_o = 1'b1;
                memRead_o = 1'b0;
                memWrite_o = 1'b0;
                branch_o = 1'b0;
                jump_o = 1'b0;
                ALUOp_o = 2'b11;
            end
            7'b0010111: begin // U-type : AUIPC
                ALUSrc_o = 1'b1;
                memToReg_o = 1'b0;
                regWrite_o = 1'b1;
                memRead_o = 1'b0;
                memWrite_o = 1'b0;
                branch_o = 1'b0;
                jump_o = 1'b0;
                ALUOp_o = 2'b00; // force add (PC + imm)
            end
            7'b1100111: begin // I-type : JALR
                ALUSrc_o = 1'b1;
                memToReg_o = 1'b0;
                regWrite_o = 1'b1;
                memRead_o = 1'b0;
                memWrite_o = 1'b0;
                branch_o = 1'b0;
                jump_o = 1'b1;
                ALUOp_o = 2'b00;
            end
            7'b1101111: begin // J-type : JAL
                ALUSrc_o = 1'b1;
                memToReg_o = 1'b0;
                regWrite_o = 1'b1;
                memRead_o = 1'b0;
                memWrite_o = 1'b0;
                branch_o = 1'b0;
                jump_o = 1'b1;
                ALUOp_o = 2'b00;
            end
            default: begin 
                ALUSrc_o = 1'b0;
                memToReg_o = 1'b0;
                regWrite_o = 1'b0;
                memRead_o = 1'b0;
                memWrite_o = 1'b0;
                branch_o = 1'b0;
                jump_o = 1'b0;
                ALUOp_o = 2'b00;
            end
        endcase
    end
    
endmodule