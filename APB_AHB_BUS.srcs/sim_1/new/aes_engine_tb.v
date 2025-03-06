`timescale 1ns/1ps

module aes_engine_tb;

    // Inputs
    reg clk;
    reg [127:0] key;
    reg [63:0] plain_addr;
    reg [1:0] width_mode;

    // Outputs
    wire [63:0] encrypted_addr;

    // Instantiate the Unit Under Test (UUT)
    aes_engine uut (
        .clk(clk),
        .key(key),
        .plain_addr(plain_addr),
        .width_mode(width_mode),
        .encrypted_addr(encrypted_addr)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test Procedure
    initial begin
        // Initialize Inputs
        key = 128'h000102030405060708090A0B0C0D0E0F; // Example AES key
        plain_addr = 64'h123456789ABCDEF0; // Example input address
        width_mode = 2'b00; // Start with 16-bit mode
        #20; // Wait for 20 time units

        // Test 16-bit Mode
        width_mode = 2'b00; // 16-bit
        plain_addr = 64'h123456789ABCDEF0;
        #20; // Wait for 20 time units
        $display("16-bit Mode: encrypted_addr = %h", encrypted_addr);

        // Test 32-bit Mode
        width_mode = 2'b01; // 32-bit
        plain_addr = 64'h123456789ABCDEF0;
        #20; // Wait for 20 time units
        $display("32-bit Mode: encrypted_addr = %h", encrypted_addr);

        // Test 64-bit Mode
        width_mode = 2'b10; // 64-bit
        plain_addr = 64'h123456789ABCDEF0;
        #20; // Wait for 20 time units
        $display("64-bit Mode: encrypted_addr = %h", encrypted_addr);

        // End Simulation
        $stop;
    end

endmodule