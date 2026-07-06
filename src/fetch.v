`timescale 1ns/1ps

module fetch (
    input clk,
    input areset_n,

    input pc_stall_i, // freezes PC when high
    input pc_src_i, // jump or branch when high
    input [31:0] pc_branch_i, // address to jump

    // to IF/ID pipeline registers
    output [31:0] pc_o, 
    output [31:0] pc4_o,
    output [31:0] instr_o
);

    // program counnter (PC)
    reg [31:0] pc_reg;
    wire [31:0] pc_4 = pc_reg + 32'd4;
    assign pc4_o = pc_4;

    always@(posedge clk or negedge areset_n) begin 
        if (!areset_n) begin 
            pc_reg <= 32'b0;
        end
        else begin 
            // if not stalled, updating the PC
            if (!pc_stall_i) begin 
                if (pc_src_i) begin // next PC MUX
                    pc_reg <= pc_branch_i; // for branch target address
                end
                else begin 
                    pc_reg <= pc_4; // PC <- PC + 4
                end
            end
        end
    end 

    assign pc_o = pc_reg;

    // instruction memory
    reg [31:0] instr_mem [1023:0]; 

    assign instr_o = instr_mem[pc_reg[31:2]]; // dropping last two bits (as byte addressable)

endmodule