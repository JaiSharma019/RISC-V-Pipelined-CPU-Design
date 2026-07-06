`timescale 1ns/1ps

module imm_gen (
    input reset_n,
    input [31:0] instr_i,
    output reg [31:0] imm_o
);

    wire [6:0] opcode;

    assign opcode = instr_i[6:0];

    always@(*) begin 
        if (!reset_n) begin 
            imm_o = 32'b0;
        end
        else begin 
            case(opcode) 
                7'b0000011: begin // I-type : load
                    imm_o = { {20{instr_i[31]}}, instr_i[31:20] };
                end
                7'b0010011: begin // I-type : arithmetic
                    imm_o = { {20{instr_i[31]}}, instr_i[31:20] };
                end
                7'b1100111: begin // I-type : JALR
                    imm_o = { {20{instr_i[31]}}, instr_i[31:20] };
                end
                7'b0100011: begin // S-type : store
                    imm_o = { {20{instr_i[31]}}, instr_i[31:25], instr_i[11:7] };
                end
                7'b1100011: begin // B-type : branch
                    imm_o = { {20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0 };
                end
                7'b0110111: begin // U-type : LUI
                    imm_o = { instr_i[31:12], 12'b0 };
                end
                7'b0010111: begin // U-type : AUIPC
                    imm_o = { instr_i[31:12], 12'b0 };
                end
                7'b1101111: begin // J-type : JAL
                    imm_o = { {12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0 };
                end
                default: begin 
                    imm_o = 32'b0;
                end
            endcase
        end
    end
    
endmodule