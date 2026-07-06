`timescale 1ns/1ps

module register_file (
    input clk,
    input rst_n,
    input en_i, // write enable
    input [4:0] rs1_i, // read address 1
    input [4:0] rs2_i, // read address 2
    input [4:0] rd_i, // write address
    input [31:0] wdata_i, // write data
    output reg [31:0] rdata1_o, // read data 1
    output reg [31:0] rdata2_o
);

    // register bank
    reg [31:0] gpr [31:0];

    // write (synchronous so that registers don't get continuously overwritten)
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // on reset clear all registers to 0
            for (i = 0; i < 32; i = i + 1) begin
                gpr[i] <= 32'b0;
            end
        end 
        // write enable must be high, and rd cannot be 0
        else if (en_i && (rd_i != 5'b00000)) begin 
            gpr[rd_i] <= wdata_i;
        end
    end

    // read (combinational so that address from IF/ID reg to data in ID/EX reg captured in a cycle)
    always @(*) begin
        // read port 1
        if (rs1_i == 5'b00000) begin
            rdata1_o = 32'b0; // register x0 is hardwired to zero
        end 
        else if (en_i && (rs1_i == rd_i)) begin
            rdata1_o = wdata_i; // internal forwarding (for preventing read-after-write hazard)
        end 
        else begin
            rdata1_o = gpr[rs1_i];
        end

        // read port 2 
        if (rs2_i == 5'b00000) begin
            rdata2_o = 32'b0; // register x0 is hardwired to zero
        end 
        else if (en_i && (rs2_i == rd_i)) begin
            rdata2_o = wdata_i; // internal forwarding
        end 
        else begin
            rdata2_o = gpr[rs2_i]; 
        end
    end
    
endmodule