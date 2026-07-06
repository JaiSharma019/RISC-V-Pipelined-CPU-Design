`timescale 1ns/1ps

module write_back (
    // from MEM/WB pipeline registers
    input [31:0] mem_wb_alu_result_i,
    input [31:0] mem_wb_read_data_i,
    input [4:0]  mem_wb_rd_addr_i,

    // control signals
    input        mem_wb_regWrite_i,
    input        mem_wb_memToReg_i,   

    // to decode stage
    output [31:0] wb_wdata_o,        // final data to be written to register file
    output [4:0]  wb_rd_addr_o,      // address to be written in there
    output        wb_regWrite_o      // enable to write
);

    // write back MUX : if memToReg = 1 -> Load Instruction, if 0 -> ALU answer
    assign wb_wdata_o = mem_wb_memToReg_i ? mem_wb_read_data_i : mem_wb_alu_result_i;
    
    // passing the pipeline registers
    assign wb_rd_addr_o  = mem_wb_rd_addr_i;
    assign wb_regWrite_o = mem_wb_regWrite_i;

endmodule