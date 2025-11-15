// Testbench for Vending Machine Controller - Moore FSM
`timescale 1ns/1ps

module tb_vending_machine_moore;
    reg clk;
    reg reset;
    reg [2:0] coin;
    wire dispense;
    wire [2:0] change;
    wire [3:0] total;
    
    // Instantiate the Unit Under Test (UUT)
    vending_machine_moore uut (
        .clk(clk),
        .reset(reset),
        .coin(coin),
        .dispense(dispense),
        .change(change),
        .total(total)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        coin = 3'b000;
        
        // Create VCD dump for waveform viewing
        $dumpfile("tb_vending_machine_moore.vcd");
        $dumpvars(0, tb_vending_machine_moore);
        
        // Display header
        $display("\n========================================");
        $display("Vending Machine Moore FSM Test");
        $display("Item Price: 7 Rupees");
        $display("========================================\n");
        
        // Release reset
        #15 reset = 0;
        #10;
        
        // Test Case 1: Exact payment with 2₹ + 5₹
        $display("Test Case 1: Insert 2₹ + 5₹ (Total = 7₹)");
        coin = 3'b010; // Insert 2₹
        #10;
        $display("  After 2₹: Total = %d, Dispense = %b, Change = %d", total, dispense, change);
        
        coin = 3'b101; // Insert 5₹
        #10;
        $display("  After 5₹: Total = %d, Dispense = %b, Change = %d", total, dispense, change);
        
        coin = 3'b000; // No coin
        #10;
        $display("  After transaction: Total = %d\n", total);
        
        // Test Case 2: Overpayment with 5₹ + 5₹ (Total = 10₹, Change = 3₹)
        $display("Test Case 2: Insert 5₹ + 5₹ (Total = 10₹, Change = 3₹)");
        coin = 3'b101; // Insert 5₹
        #10;
        $display("  After 1st 5₹: Total = %d, Dispense = %b, Change = %d", total, dispense, change);
        
        coin = 3'b101; // Insert 5₹
        #10;
        $display("  After 2nd 5₹: Total = %d, Dispense = %b, Change = %d", total, dispense, change);
        
        coin = 3'b000; // No coin
        #10;
        $display("  After transaction: Total = %d\n", total);
        
        // Test Case 3: Payment with 1₹ coins (1₹ × 7)
        $display("Test Case 3: Insert seven 1₹ coins");
        repeat(7) begin
            coin = 3'b001; // Insert 1₹
            #10;
            $display("  Total = %d, Dispense = %b, Change = %d", total, dispense, change);
        end
        
        coin = 3'b000; // No coin
        #10;
        $display("  After transaction: Total = %d\n", total);
        
        // Test Case 4: Mixed coins (1₹ + 1₹ + 2₹ + 2₹ + 1₹)
        $display("Test Case 4: Insert 1₹ + 1₹ + 2₹ + 2₹ + 1₹ (Total = 7₹)");
        coin = 3'b001; #10; $display("  1₹: Total = %d", total);
        coin = 3'b001; #10; $display("  1₹: Total = %d", total);
        coin = 3'b010; #10; $display("  2₹: Total = %d", total);
        coin = 3'b010; #10; $display("  2₹: Total = %d", total);
        coin = 3'b001; #10; $display("  1₹: Total = %d, Dispense = %b, Change = %d", total, dispense, change);
        
        coin = 3'b000; // No coin
        #10;
        $display("  After transaction: Total = %d\n", total);
        
        // Test Case 5: Overpayment (2₹ + 2₹ + 5₹ = 9₹, Change = 2₹)
        $display("Test Case 5: Insert 2₹ + 2₹ + 5₹ (Total = 9₹, Change = 2₹)");
        coin = 3'b010; #10; $display("  2₹: Total = %d", total);
        coin = 3'b010; #10; $display("  2₹: Total = %d", total);
        coin = 3'b101; #10; $display("  5₹: Total = %d, Dispense = %b, Change = %d", total, dispense, change);
        
        coin = 3'b000; // No coin
        #10;
        $display("  After transaction: Total = %d\n", total);
        
        // Test Case 6: Reset during transaction
        $display("Test Case 6: Reset during transaction");
        coin = 3'b101; #10; $display("  5₹: Total = %d", total);
        coin = 3'b001; #10; $display("  1₹: Total = %d", total);
        reset = 1; #10;
        $display("  Reset asserted: Total = %d", total);
        reset = 0; #10;
        $display("  After reset: Total = %d\n", total);
        
        // Test Case 7: Invalid coin (no coin inserted for several cycles)
        $display("Test Case 7: No coins inserted");
        coin = 3'b000;
        repeat(5) begin
            #10;
            $display("  Total = %d, Dispense = %b", total, dispense);
        end
        
        $display("\n========================================");
        $display("All tests completed!");
        $display("========================================\n");
        
        #20;
        $finish;
    end
    
    // Monitor for automatic output tracking
    initial begin
        $monitor("Time=%0t | Coin=%b | Total=%d | Dispense=%b | Change=%d", 
                 $time, coin, total, dispense, change);
    end
    
endmodule
