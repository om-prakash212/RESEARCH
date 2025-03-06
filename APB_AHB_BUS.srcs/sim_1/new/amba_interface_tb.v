`timescale 1ns / 1ps

module amba_interface_tb;

    // Inputs
    reg HCLK;
    reg HRESETn;
    reg [1:0] current_width;
    reg [63:0] encrypted_addr;

    // Outputs
    wire HREADY;
    wire [63:0] HADDR;
    wire [2:0] HSIZE;

    // Instantiate the Unit Under Test (UUT)
    amba_interface uut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .current_width(current_width),
        .encrypted_addr(encrypted_addr),
        .HREADY(HREADY),
        .HADDR(HADDR),
        .HSIZE(HSIZE)
    );

    // Clock generation
    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        HRESETn = 0;
        current_width = 2'b00;
        encrypted_addr = 64'h0000000000000000;

        // Apply reset
        #20;
        HRESETn = 1;

        // Test case 1: 16-bit width
        #10;
        current_width = 2'b00;
        encrypted_addr = 64'h123456789ABCDEF0;

        // Test case 2: 32-bit width
        #10;
        current_width = 2'b01;
        encrypted_addr = 64'hFEDCBA9876543210;

        // Test case 3: 64-bit width
        #10;
        current_width = 2'b10;
        encrypted_addr = 64'hDEADBEEFDEADBEEF;

        // Test case 4: Default width (32-bit)
        #10;
        current_width = 2'b11; // Invalid width, should default to 32-bit
        encrypted_addr = 64'hCAFEBABECAFEBABE;

        // End simulation
        #10;
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | HRESETn: %b | current_width: %b | encrypted_addr: %h | HREADY: %b | HADDR: %h | HSIZE: %b",
                 $time, HRESETn, current_width, encrypted_addr, HREADY, HADDR, HSIZE);
    end

endmodule