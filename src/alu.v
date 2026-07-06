`timescale 1ns/1ps

module alu (
    input [31:0] a_i,
    input [31:0] b_i,
    input [3:0] ctrl_i,
    output reg [31:0] out_o,
    output zero_o
);

    assign zero_o = (out_o==32'b0);

    always @(*) begin
        
        case (ctrl_i) 
            4'b0010: begin // ADD
                out_o = a_i + b_i;
            end
            4'b0110: begin // SUB
                out_o = a_i - b_i;
            end
            4'b1001: begin // SLL
                out_o = a_i << b_i[4:0];
            end
            4'b0111: begin // SLT
                out_o = ($signed(a_i) < $signed(b_i)) ? 32'd1 : 32'd0;
            end
            4'b1000: begin // SLTU
                out_o = (a_i < b_i) ? 32'd1 : 32'd0;
            end
            4'b0100: begin // XOR
                out_o = a_i ^ b_i;
            end
            4'b0101: begin // SRL
                out_o = a_i >> b_i[4:0];
            end
            4'b1101: begin // SRA
                out_o = $signed(a_i) >>> b_i[4:0];
            end
            4'b0001: begin // OR
                out_o = a_i | b_i;
            end
            4'b0000: begin // AND
                out_o = a_i & b_i;
            end
            4'b1100: begin // NOR
                out_o = ~(a_i | b_i);
            end
            default: begin 
                out_o = 32'b0;
            end
        endcase
    end
    
endmodule