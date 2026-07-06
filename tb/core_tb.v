// `timescale 1ns/1ps

// module tb_core;

//     // 1. Declare testbench signals
//     reg clk;
//     reg reset_n;

//     // 2. Instantiate the core
//     core uut (
//         .clk(clk),
//         .reset_n(reset_n)
//     );

//     // 3. Clock generator (100MHz)
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end

//     // // --- CYCLE TRACKER & HARDWARE LOGGER ---
//     // integer cycle_count = 0;
    
//     // always @(posedge clk) begin
//     //     if (reset_n) begin
//     //         cycle_count = cycle_count + 1;
            
//     //         // Watch the Writeback stage. If Write Enable is high, and it's not register x0:
//     //         if (uut.WB.wb_regWrite_o && (uut.WB.wb_rd_addr_o != 5'b0)) begin
//     //             $display("[Cycle %4d] Task Finished -> Saved Hex: %8h to Register x%0d", 
//     //                      cycle_count, uut.WB.wb_wdata_o, uut.WB.wb_rd_addr_o);
//     //         end
//     //     end
//     // end
//     // --- ADVANCED PIPELINE TRACER ---
//     integer cycle_count = 0;
    
//     // always @(posedge clk) begin
//     //     if (reset_n) begin
//     //         cycle_count = cycle_count + 1;
            
//     //         $display("===============================================================================");
//     //         $display("CLOCK CYCLE %4d", cycle_count);
//     //         $display("-------------------------------------------------------------------------------");
            
//     //         // 1. FETCH STAGE
//     //         $display(" [IF]  Fetching PC : %8h | Instruction: %8h", 
//     //                  uut.IF.pc_o, uut.IF.instr_o);
            
//     //         // 2. DECODE STAGE (Looking at the IF/ID register)
//     //         $display(" [ID]  Decoding PC : %8h | rs1: x%0d, rs2: x%0d, rd: x%0d | Imm: %8h", 
//     //                  uut.if_id_pc, uut.ID.rs1, uut.ID.rs2, uut.ID.rd, uut.id_imm_out);
            
//     //         // 3. EXECUTE STAGE (Looking at the ID/EX register)
//     //         $display(" [EX]  Executing PC: %8h | ALU In1: %8h | ALU In2: %8h | ALU Out: %8h", 
//     //                  uut.id_ex_pc, uut.EX.alu_in1, uut.EX.alu_in2, uut.EX.alu_math_result);
            
//     //         // 4. MEMORY STAGE (Looking at the EX/MEM register)
//     //         $display(" [MEM] Mem Addr    : %8h | Write Data: %8h | Read Enable: %b | Write Enable: %b", 
//     //                  uut.ex_mem_alu_result, uut.ex_mem_rs2_data, uut.ex_mem_memRead, uut.ex_mem_memWrite);
            
//     //         // 5. WRITEBACK STAGE (Looking at the MEM/WB register)
//     //         $display(" [WB]  Saving Data : %8h | To Reg: x%0d     | RegWrite: %b", 
//     //                  uut.wb_wdata_out, uut.wb_rd_addr_out, uut.wb_regWrite_out);
            
//     //         $display("-------------------------------------------------------------------------------");
            
//     //         // HAZARD & CONTROL TRACKING
//     //         if (uut.stall_hazard) begin
//     //             $display(" *** BUBBLE INJECTED: Load-Use Hazard Detected! IF and ID stages frozen. ***");
//     //         end
//     //         if (uut.pc_src) begin
//     //             $display(" *** PIPELINE FLUSH: Branch/Jump Taken! Target PC: %8h. Flushing IF & ID. ***", uut.target_pc);
//     //         end
            
//     //         $display("===============================================================================\n");
//     //     end
//     // end

//     // // 4. Reset & Simulation Controller
//     // integer i;
//     // initial begin
//     //     // --- STEP A: Assert Reset (Active Low) ---
//     //     reset_n = 0; 
        
//     //     // --- STEP B: Wait for a few cycles (Reset held for 20ns) ---
//     //     #20;
        
//     //     // --- STEP C: Release Reset (Processor begins execution) ---
//     //     reset_n = 1;
        
//     // //     // --- STEP D: Run the test ---
//     // //     #500;
        
//     // //     // --- STEP E: Finish ---
//     // //     $finish;
//     // // end
//     // #510; 
        
//     //     $display("\n=======================================================");
//     //     $display("   FINAL DATA MEMORY DUMP (Fibonacci Sequence)         ");
//     //     $display("=======================================================");
        
//     //     // // Loop through the first 5 Word addresses (0, 1, 2, 3, 4)
//     //     // for (i = 0; i < 5; i = i + 1) begin
//     //     //     // NOTE: Change 'uut' to whatever you named your core instance in the testbench
//     //     //     // NOTE: Change 'data_mem' to whatever you named the array in your memory.v file
//     //     //     $display(" Memory Word [%0d] (Addr 0x%02h) : %0d", i, i*4, uut.MEM.mem[i]);
//     //     // end
//     //     // Loop through the first 5 Word addresses
//     //     for (i = 0; i < 5; i = i + 1) begin
//     //         $display(" Memory Word [%0d] (Addr 0x%02h) : %0d", i, i*4, 
//     //                 {uut.MEM.mem[i*4+3], uut.MEM.mem[i*4+2], uut.MEM.mem[i*4+1], uut.MEM.mem[i*4+0]});
//     //     end
        
//     //     $display("=======================================================\n");
        
//     //     // Give it 10 more time units and then kill the simulation
//     //     #10;
//     //     $finish;
//     // end

//     // 5. Load memory and dump waveforms
//     integer k;
//     initial begin
//         // Ensure you have program.hex in the same directory
//         $readmemh("program.hex", uut.IF.instr_mem);
//         // Load the variables/arrays into the Data Memory stage
//         $readmemh("program.hex", uut.MEM.mem);
        
//         // Dump the core AND the internal register file for debugging
//         $dumpfile("core_tb.vcd");
//         $dumpvars(0, tb_core);
//         // for (k = 0; k < 32; k = k + 1) begin
//         //     $dumpvars(0, uut.ID.regFile.gpr[k]);
//         // end
//     end

//     // integer i;
//     // initial begin
//     //     reset_n = 0; 
//     //     #20;
//     //     reset_n = 1;
        
//     //     #3000; // Let the processor crunch the algorithm
        
//     //     $display("\n=======================================================");
//     //     $display("   FINAL DATA MEMORY DUMP (Bellman-Ford Distances)     ");
//     //     $display("=======================================================");
        
//     //     // Print the distances to Nodes 0, 1, 2, and 3
//     //     for (i = 20; i < 24; i = i + 1) begin
//     //         $display(" Distance to Node [%0d] : %0d", i-20, 
//     //                 {uut.MEM.mem[i][31:24], uut.MEM.mem[i][23:16], uut.MEM.mem[i][15:8], uut.MEM.mem[i][7:0]});
//     //     end
        
//     //     $display("=======================================================\n");
//     //     $finish;
//     // end
//     // integer i;
//     // initial begin
//     //     reset_n = 0; 
//     //     #20;
//     //     reset_n = 1;
        
//     //     #15000; // Let the C code finish
        
//     //     $display("\n=======================================================");
//     //     $display("   FINAL DATA MEMORY DUMP (Vector Addition array_c)    ");
//     //     $display("=======================================================");
        
//     //     // GCC placed array_c starting at Word Index 47
//     //     for (i = 47; i < 52; i = i + 1) begin
//     //         $display(" Memory Word [%0d] (Addr 0x%02h) : %0d", i, i*4, uut.MEM.mem[i]);
//     //     end
        
//     //     $display("=======================================================\n");
//     //     $finish;
//     // end
//     integer i;
//     initial begin
//         reset_n = 0; 
//         #20;
//         reset_n = 1;
        
//         #500; // Let the hardware crunch the 5 loops
        
//         $display("\n=======================================================");
//         $display("   FINAL DATA MEMORY DUMP (Fibonacci Sequence)         ");
//         $display("=======================================================");
        
//         // Print Words 0 through 4
//         for (i = 0; i < 5; i = i + 1) begin
//             $display(" Memory Word [%0d] (Addr 0x%02h) : %0d", i, i*4, uut.MEM.mem[i]);
//         end
        
//         $display("=======================================================\n");
//         $finish;
//     end

// endmodule

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