
`timescale 1ns/1ps

module tb_single_cycle;

    reg clk;
    reg rst;

    integer cycle;
    integer failures;

    reg saw_fetch_00;
    reg saw_fetch_04;
    reg saw_fetch_08;
    reg saw_fetch_0C;
    reg saw_fetch_10;
    reg saw_fetch_14;
    reg saw_fetch_18;
    reg saw_fetch_1C;

    single_cycle_top dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    // ------------------------------------------------
    // GENERAL CHECK TASK
    // ------------------------------------------------

    task check;
        input [255:0] name;
        input condition;
        begin
            if (condition === 1'b1) begin
                $display("PASS: %0s", name);
            end
            else begin
                $display("FAIL: %0s", name);
                failures = failures + 1;
            end
        end
    endtask

    // ------------------------------------------------
    // X/Z CHECK TASK
    // ------------------------------------------------

    task check_no_xz;
        input [255:0] name;
        input [31:0] value;

        integer i;
        reg contains_xz;

        begin
            contains_xz = 1'b0;

            for (i = 0; i < 32; i = i + 1) begin
                if ((value[i] === 1'bx) ||
                    (value[i] === 1'bz)) begin
                    contains_xz = 1'b1;
                end
            end

            if (contains_xz) begin
                $display("FAIL: %0s contains X/Z", name);
                failures = failures + 1;
            end
            else begin
                $display("PASS: %0s has no X/Z", name);
            end
        end
    endtask

    // ------------------------------------------------
    // MAIN TEST
    // ------------------------------------------------

    initial begin

        clk = 1'b0;
        rst = 1'b0;

        cycle = 0;
        failures = 0;

        saw_fetch_00 = 1'b0;
        saw_fetch_04 = 1'b0;
        saw_fetch_08 = 1'b0;
        saw_fetch_0C = 1'b0;
        saw_fetch_10 = 1'b0;
        saw_fetch_14 = 1'b0;
        saw_fetch_18 = 1'b0;
        saw_fetch_1C = 1'b0;

        // ============================================
        // 1. RESET TEST
        // ============================================

        repeat (2) @(posedge clk);
        @(negedge clk);
        #1;

        check("Active-low reset initializes PC",
              dut.PC === 32'h00000000);

        check("Register x0 reset",
              dut.rf.register[0] === 32'd0);

        check("Register x1 reset",
              dut.rf.register[1] === 32'd0);

        // Release reset
        rst = 1'b1;
        #1;

        // ============================================
        // 2. INITIAL INSTRUCTION FETCH
        // ============================================

        check("Initial PC is zero",
              dut.PC === 32'h00000000);

        check("ADDI x1,x0,5 fetched at 0x00",
              dut.instruction === 32'h00500093);

        // IMPORTANT: Record the first fetch BEFORE
        // the first active clock edge advances the PC.
        if ((dut.PC === 32'h00000000) &&
            (dut.instruction === 32'h00500093)) begin
            saw_fetch_00 = 1'b1;
        end

        // ============================================
        // 3. INSTRUCTION MEMORY CONTENT CHECK
        // ============================================

        check("Program instruction 0 loaded",
              dut.imem.memory[0] === 32'h00500093);

        check("Program instruction 1 loaded",
              dut.imem.memory[1] === 32'h00300113);

        check("Program instruction 2 loaded",
              dut.imem.memory[2] === 32'h002081B3);

        check("Program instruction 3 loaded",
              dut.imem.memory[3] === 32'h00302023);

        check("Program instruction 4 loaded",
              dut.imem.memory[4] === 32'h00002203);

        check("Program instruction 5 loaded",
              dut.imem.memory[5] === 32'h00320463);

        check("Program instruction 6 loaded",
              dut.imem.memory[6] === 32'h06300293);

        check("Program instruction 7 loaded",
              dut.imem.memory[7] === 32'h00700293);

        // ============================================
        // 4. EXECUTION AND FETCH MONITOR
        // ============================================

        while (cycle < 12) begin

            @(negedge clk);
            #1;

            case (dut.PC)

                32'h00000000: begin
                    saw_fetch_00 = 1'b1;

                    check("Instruction at 0x00",
                          dut.instruction === 32'h00500093);
                end

                32'h00000004: begin
                    saw_fetch_04 = 1'b1;

                    check("Instruction at 0x04",
                          dut.instruction === 32'h00300113);
                end

                32'h00000008: begin
                    saw_fetch_08 = 1'b1;

                    check("Instruction at 0x08",
                          dut.instruction === 32'h002081B3);
                end

                32'h0000000C: begin
                    saw_fetch_0C = 1'b1;

                    check("Instruction at 0x0C",
                          dut.instruction === 32'h00302023);
                end

                32'h00000010: begin
                    saw_fetch_10 = 1'b1;

                    check("Instruction at 0x10",
                          dut.instruction === 32'h00002203);
                end

                32'h00000014: begin
                    saw_fetch_14 = 1'b1;

                    check("BEQ instruction at 0x14",
                          dut.instruction === 32'h00320463);

                    check("BEQ operand 1 equals 8",
                          dut.RD1 === 32'd8);

                    check("BEQ operand 2 equals 8",
                          dut.RD2 === 32'd8);

                    check("BEQ branch is taken",
                          dut.branch_taken === 1'b1 &&
                          dut.PC_Src === 1'b1);
                end

                32'h00000018: begin
                    saw_fetch_18 = 1'b1;
                end

                32'h0000001C: begin
                    saw_fetch_1C = 1'b1;

                    check("Branch destination instruction",
                          dut.instruction === 32'h00700293);
                end

                default: begin
                    $display("INFO: PC = %h", dut.PC);
                end

            endcase

            // Check for unknown values
            check_no_xz("PC", dut.PC);
            check_no_xz("Instruction", dut.instruction);
            check_no_xz("PC_Next", dut.PC_Next);
            check_no_xz("ALU_Result", dut.ALU_Result);
            check_no_xz("WriteBack", dut.WriteBack);

            cycle = cycle + 1;

        end

        // ============================================
        // 5. REGISTER FILE CHECKS
        // ============================================

        check("x1 equals 5",
              dut.rf.register[1] === 32'd5);

        check("x2 equals 3",
              dut.rf.register[2] === 32'd3);

        check("x3 equals 8",
              dut.rf.register[3] === 32'd8);

        check("x4 equals 8",
              dut.rf.register[4] === 32'd8);

        check("x5 equals 7",
              dut.rf.register[5] === 32'd7);

        check("x0 remains zero",
              dut.rf.register[0] === 32'd0);

        // ============================================
        // 6. DATA MEMORY CHECK
        // ============================================

        check("Memory address 0 contains 8",
              dut.dmem.data_mem[0] === 32'd8);

        // ============================================
        // 7. PROGRAM FLOW CHECKS
        // ============================================

        check("Instruction at 0x00 fetched",
              saw_fetch_00);

        check("Instruction at 0x04 fetched",
              saw_fetch_04);

        check("Instruction at 0x08 fetched",
              saw_fetch_08);

        check("Instruction at 0x0C fetched",
              saw_fetch_0C);

        check("Instruction at 0x10 fetched",
              saw_fetch_10);

        check("BEQ at 0x14 fetched",
              saw_fetch_14);

        check("Instruction at 0x18 skipped",
              !saw_fetch_18);

        check("Branch destination 0x1C fetched",
              saw_fetch_1C);

        // ============================================
        // 8. FINAL SUMMARY
        // ============================================

        $display("------------------------------------");
        $display("RISC-V SINGLE-CYCLE TEST SUMMARY");
        $display("------------------------------------");

        if (failures == 0) begin
            $display("FINAL SUMMARY: ALL TESTS PASSED");
        end
        else begin
            $display("FINAL SUMMARY: FAILURES = %0d",
                     failures);
        end

        $display("------------------------------------");

        $finish;

    end

endmodule
