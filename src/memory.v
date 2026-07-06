`timescale 1ns/1ps

module memory #(
    parameter DEPTH = 4096
) (
    input clk,
    input reset_n,

    // from EX/MEM pipeline registers
    input [31:0] ex_mem_alu_result_i, // memory address or arithmentic answer
    input [31:0] ex_mem_rs2_data_i,   // data to store
    input [4:0]  ex_mem_rd_addr_i,
    input [2:0]  ex_mem_funct3_i,

    // control signals
    input        ex_mem_memRead_i,
    input        ex_mem_memWrite_i,
    input        ex_mem_regWrite_i,
    input        ex_mem_memToReg_i,

    // to MEM/WB pipeline registers
    output reg [31:0] mem_wb_read_data_o,  // data loaded
    output [31:0] mem_wb_alu_result_o, // arithmetic answer passed
    output [4:0]  mem_wb_rd_addr_o,

    // out control signals
    output        mem_wb_regWrite_o,
    output        mem_wb_memToReg_o
);

    reg [31:0] mem [0:(DEPTH/4)-1];

    // address decoding
    wire [29:0] word_addr = ex_mem_alu_result_i[31:2];
    wire [1:0] byte_offset = ex_mem_alu_result_i[1:0];
    wire [31:0] current_word = mem[word_addr];

    // reading from memory
    always @(*) begin 
        mem_wb_read_data_o = 32'b0;
        if (ex_mem_memRead_i) begin 
            case (ex_mem_funct3_i)
                3'b010: begin // LW — load word (32-bit)
                    mem_wb_read_data_o = current_word;
                end
                3'b001: begin // LH — load halfword, signed
                    if (byte_offset[1]) 
                        mem_wb_read_data_o = {{16{current_word[31]}}, current_word[31:16]};
                    else                
                        mem_wb_read_data_o = {{16{current_word[15]}}, current_word[15:0]};
                end
                3'b101: begin // LHU — load halfword, unsigned
                    if (byte_offset[1]) 
                        mem_wb_read_data_o = {16'b0, current_word[31:16]};
                    else                
                        mem_wb_read_data_o = {16'b0, current_word[15:0]};
                end
                3'b000: begin // LB — load byte, signed
                    case (byte_offset)
                        2'b00: mem_wb_read_data_o = {{24{current_word[7]}},  current_word[7:0]};
                        2'b01: mem_wb_read_data_o = {{24{current_word[15]}}, current_word[15:8]};
                        2'b10: mem_wb_read_data_o = {{24{current_word[23]}}, current_word[23:16]};
                        2'b11: mem_wb_read_data_o = {{24{current_word[31]}}, current_word[31:24]};
                    endcase
                end
                3'b100: begin // LBU — load byte, unsigned
                    case (byte_offset)
                        2'b00: mem_wb_read_data_o = {24'b0, current_word[7:0]};
                        2'b01: mem_wb_read_data_o = {24'b0, current_word[15:8]};
                        2'b10: mem_wb_read_data_o = {24'b0, current_word[23:16]};
                        2'b11: mem_wb_read_data_o = {24'b0, current_word[31:24]};
                    endcase
                end
                default: mem_wb_read_data_o = 32'b0;
            endcase
        end
    end

    // writing from memory
    always @(posedge clk) begin
        if (!reset_n) begin 
            mem[word_addr] <= 0;
        end
        else begin 
            if (ex_mem_memWrite_i) begin 
                case (ex_mem_funct3_i)
                    3'b010: begin // SW — store word (overwrites all 4 lanes)
                        mem[word_addr] <= ex_mem_rs2_data_i;
                    end
                    3'b001: begin // SH — store halfword (overwrites 2 lanes)
                        if (byte_offset[1])
                            mem[word_addr][31:16] <= ex_mem_rs2_data_i[15:0];
                        else
                            mem[word_addr][15:0]  <= ex_mem_rs2_data_i[15:0];
                    end
                    3'b000: begin // SB — store byte (overwrites 1 lane)
                        case (byte_offset)
                            2'b00: mem[word_addr][7:0]   <= ex_mem_rs2_data_i[7:0];
                            2'b01: mem[word_addr][15:8]  <= ex_mem_rs2_data_i[7:0];
                            2'b10: mem[word_addr][23:16] <= ex_mem_rs2_data_i[7:0];
                            2'b11: mem[word_addr][31:24] <= ex_mem_rs2_data_i[7:0];
                        endcase
                    end
                endcase
            end

        end 
    end

    // passing other pipeline registers
    assign mem_wb_alu_result_o = ex_mem_alu_result_i;
    assign mem_wb_rd_addr_o    = ex_mem_rd_addr_i;
    assign mem_wb_regWrite_o   = ex_mem_regWrite_i;
    assign mem_wb_memToReg_o   = ex_mem_memToReg_i;
    
endmodule