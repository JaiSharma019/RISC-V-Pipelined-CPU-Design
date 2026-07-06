`timescale 1ns/1ps

module alu_control (
    input [1:0] ALUOp_i,
    input [2:0] funct3_i,
    input funct7_30_i,

    output reg [3:0] alu_ctrl_o
);

    always@(*) begin 
        alu_ctrl_o = 4'b0000; // default
        case(ALUOp_i) 
            2'b00: begin // for memory : PC address added
                alu_ctrl_o = 4'b0010;
            end
            2'b01: begin // for branches : subtract
                alu_ctrl_o = 4'b0110;
            end
            2'b10: begin // arithmetic/logic instructions 
                case(funct3_i) 
                    3'b000: begin 
                        if (funct7_30_i) alu_ctrl_o = 4'b0110; // subtract
                        else alu_ctrl_o = 4'b0010; // add
                    end
                    3'b001: alu_ctrl_o = 4'b1001; // SLL
                    3'b010: alu_ctrl_o = 4'b0111; // SLT
                    3'b011: alu_ctrl_o = 4'b1000; // SLTU
                    3'b100: alu_ctrl_o = 4'b0100; // XOR
                    3'b101: begin 
                        if (funct7_30_i) alu_ctrl_o = 4'b1101; // SRA
                        else alu_ctrl_o = 4'b0101; // SRL
                    end
                    3'b110: alu_ctrl_o = 4'b0001; // OR
                    3'b111: alu_ctrl_o = 4'b0000; // AND
                    default: alu_ctrl_o = 4'b0000;
                endcase
            end
            2'b11: begin // for LUI : add
                alu_ctrl_o = 4'b0010;
            end
            default: begin 
                alu_ctrl_o = 4'b0000;
            end
        endcase
    end
    
endmodule