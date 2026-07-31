`timescale 1ns/1ps

module tb_core;

    reg clk;
    reg reset_n;

    core uut (
        .clk(clk),
        .reset_n(reset_n)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer cycle_count = 0;
    integer stall_count = 0;
    integer flush_count = 0;
    integer instr_count = 0;
    
    
    reg program_halted = 0;

    always @(posedge clk) begin
        if (reset_n && !program_halted) begin
            cycle_count = cycle_count + 1;
            
            // Snooping the internal hazard and flush signals
            if (uut.stall_hazard) begin
                stall_count = stall_count + 1;
            end 
            else if (uut.pc_src) begin
                flush_count = flush_count + 1;
            end
            else begin
                
                instr_count = instr_count + 1;
            end

            if (uut.if_id_pc == uut.target_pc && uut.pc_src) begin
                program_halted = 1;
            end
        end
    end


    initial begin
        // Ensure you have program.hex in the same directory
        $readmemh("software/program.hex", uut.IF.instr_mem);
        $readmemh("software/program.hex", uut.MEM.mem);
        
        $dumpfile("core_tb.vcd");
        $dumpvars(0, tb_core);
    end
    
    real cpi, ipc;

    initial begin
        reset_n = 0; 
        #20;
        reset_n = 1;
        
        wait(program_halted == 1);
        
        // extra time to drain final instructions
        #50;
        
        instr_count = instr_count - 4; // subtract the pipeline fill bubbles
        // Calculate Metrics
        // subtracting the 4 cycle pipeline fill time for accurate CPI
        cpi = (cycle_count - 4.0) / instr_count; 
        ipc = 1.0 / cpi;

        $display("\n Results:");
        $display(" Total Clock Cycles Executed : %0d", cycle_count);
        $display(" Total Instructions Retired  : %0d", instr_count);
        $display(" Data Hazard Stalls (Bubbles): %0d", stall_count);
        $display(" Branch Penalties (Flushes)  : %0d", flush_count);
        $display(" CPI (Cycles Per Instruction): %0.3f", cpi);
        $display(" IPC (Instructions Per Cycle): %0.3f", ipc);

        // instead of printing specific variables, dumping the whole RAM to file
        $writememh("software/final_memory_dump.hex", uut.MEM.mem);
        $display(" [INFO] Final memory state saved to 'software/final_memory_dump.hex'");
        
        $finish;
    end

    // for safety timeout
    initial begin
        #50000; // giving the processor 10,000 clock cycles to finish
        $display("\n *** ERROR: Simulation Timeout! Processor stuck. ***\n");
        $finish;
    end

endmodule