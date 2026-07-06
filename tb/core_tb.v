`timescale 1ns/1ps

module tb_core;

    // 1. Declare testbench signals
    reg clk;
    reg reset_n;

    // 2. Instantiate the core
    core uut (
        .clk(clk),
        .reset_n(reset_n)
    );

    // 3. Clock generator (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- 4. HARDWARE PERFORMANCE COUNTERS ---
    integer cycle_count = 0;
    integer stall_count = 0;
    integer flush_count = 0;
    integer instr_count = 0;
    
    // We will track when the program finishes by looking for the infinite loop trap (JAL to itself)
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
                // In a perfect 5-stage scalar pipeline, 1 cycle without a stall/flush = 1 instruction fetched
                instr_count = instr_count + 1;
            end

            // // Detect Program Halt (PC stops moving, indicating the 'end: jal x0, end' trap)
            // if (uut.if_pc_out == uut.target_pc && uut.pc_src) begin
            //     program_halted = 1;
            // end
            // Detect Program Halt (Instruction jumps to itself)
            if (uut.if_id_pc == uut.target_pc && uut.pc_src) begin
                program_halted = 1;
            end
        end
    end

    // 5. Load memory and dump waveforms
    initial begin
        // Ensure you have program.hex in the same directory
        $readmemh("software/program.hex", uut.IF.instr_mem);
        $readmemh("software/program.hex", uut.MEM.mem);
        
        $dumpfile("core_tb.vcd");
        $dumpvars(0, tb_core);
    end

    // 6. Reset & Simulation Controller
    
    real cpi, ipc;

    initial begin
        reset_n = 0; 
        #20;
        reset_n = 1;
        
        // Wait for the hardware monitor to detect the program halt
        wait(program_halted == 1);
        
        // Give the pipeline 5 extra cycles to drain the final instructions into memory
        #50;
        
        instr_count = instr_count - 4; // Subtract the pipeline fill bubbles
        // Calculate Metrics
        // Note: Subtracting the 4 cycle pipeline fill time for accurate CPI
        cpi = (cycle_count - 4.0) / instr_count; 
        ipc = 1.0 / cpi;

        $display("\n=======================================================");
        $display("   SILICON PERFORMANCE REPORT                          ");
        $display("=======================================================");
        $display(" Total Clock Cycles Executed : %0d", cycle_count);
        $display(" Total Instructions Retired  : %0d", instr_count);
        $display(" Data Hazard Stalls (Bubbles): %0d", stall_count);
        $display(" Branch Penalties (Flushes)  : %0d", flush_count);
        $display("-------------------------------------------------------");
        $display(" CPI (Cycles Per Instruction): %0.3f", cpi);
        $display(" IPC (Instructions Per Cycle): %0.3f", ipc);
        $display("=======================================================\n");

        // $display("=======================================================");
        // $display("   FINAL DATA MEMORY DUMP (First 10 Words)             ");
        // $display("=======================================================");
        // for (i = 0; i < 10; i = i + 1) begin
        //     $display(" Memory Word [%0d] (Addr 0x%02h) : %0d", i, i*4, uut.MEM.mem[i]);
        // end
        // $display("=======================================================");
        // $display("   FINAL DATA MEMORY DUMP (Smart Array Scanner)        ");
        // $display("=======================================================");
        
        // // Start scanning after the instructions (Word 100) up to Word 300
        // for (i = 100; i <= 300; i = i + 1) begin
        //     // Only print the memory slot if it actually contains something
        //     if (uut.MEM.mem[i] != 0 && uut.MEM.mem[i] !== 32'bx) begin
        //         $display(" Memory Word [%0d] (Addr 0x%02h) : %0d", i, i*4, uut.MEM.mem[i]);
        //     end
        // end
        // $display("=======================================================");
        // $display("   FINAL DATA MEMORY DUMP (Global Discovery Scanner)   ");
        // $display("=======================================================");
        
        // // Scan the entire 1024-word memory
        // for (i = 0; i < 1024; i = i + 1) begin
        //     // Filter out 0 (empty) and instructions (we know instructions start around 0x00)
        //     // This will reveal your array variables sitting in the .data section
        //     if (uut.MEM.mem[i] != 0 && uut.MEM.mem[i] !== 32'bx && i > 40) begin
        //         $display(" Memory Word [%0d] (Addr 0x%02h) : %0d", i, i*4, uut.MEM.mem[i]);
        //     end
        // end
        // $display("=======================================================\n");
        // $display("=======================================================\n");
        // $display("=======================================================");
        // $display("   FINAL DATA MEMORY DUMP (Pinned Array at Word 256)   ");
        // $display("=======================================================");
        // for (i = 256; i <= 264; i = i + 1) begin
        //     $display(" Memory Word [%0d] (Addr 0x%02h) : %0d", i, i*4, uut.MEM.mem[i]);
        // end
        // $display("=======================================================\n");
        // $display("=======================================================");
        // $display("   FINAL MEMORY SIGNATURE (Target Outputs Only)        ");
        // $display("=======================================================");
        
        // // Print exactly the 5 words we allocated in the signature region
        // for (i = 512; i < 517; i = i + 1) begin
        //     $display(" Output [%0d] (Addr 0x%02h) : %0d", i-512, i*4, uut.MEM.mem[i]);
        // end
        
        // $display("=======================================================\n");
        // $display("=======================================================");
        // $display("   FINAL MEMORY SIGNATURE (3x3 Matrix Output)          ");
        // $display("=======================================================");
        
        // // Print the 9 words of the output matrix
        // for (i = 512; i < 521; i = i + 1) begin
        //     $display(" Output [%0d] (Addr 0x%02h) : %0d", i-512, i*4, uut.MEM.mem[i]);
        // end
        
        // $display("=======================================================\n");
        // $display("=======================================================");
        // $display("   FINAL MEMORY SIGNATURE (Bellman-Ford Distances)     ");
        // $display("=======================================================");
        
        // // Print the 4 shortest path distances
        // for (i = 512; i < 516; i = i + 1) begin
        //     $display(" Node [%0d] (Addr 0x%02h) : %0d", i-512, i*4, uut.MEM.mem[i]);
        // end
        
        // $display("=======================================================\n");
        // $display("=======================================================");
        // $display("   FINAL MEMORY SIGNATURE (Pointer Chasing Output)     ");
        // $display("=======================================================");
        
        // $display(" Total Sum   (Addr 0x0800) : %0d", uut.MEM.mem[512]);
        // $display(" Node Count  (Addr 0x0804) : %0d", uut.MEM.mem[513]);
        // $display(" Final Value (Addr 0x0808) : %0d", uut.MEM.mem[514]);
        
        // $display("=======================================================\n");
        // --- NEW UNIVERSAL DATA DUMP ---
        // Instead of printing specific variables, dump the whole RAM to a file!
        $writememh("software/final_memory_dump.hex", uut.MEM.mem);
        $display(" [INFO] Final memory state saved to 'software/final_memory_dump.hex'");
        $display("=======================================================\n");
        
        $finish;
    end

    // 7. Safety Timeout Thread
    initial begin
        #50000; // Gives the processor 10,000 clock cycles to finish
        $display("\n *** ERROR: Simulation Timeout! Processor stuck. ***\n");
        $finish;
    end

endmodule