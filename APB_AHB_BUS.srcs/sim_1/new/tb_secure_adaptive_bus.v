`timescale 1ns/1ps

module tb_secure_adaptive_bus;

    // Clock and Reset
    reg clk;
    reg rst;

    // Inputs
    reg [63:0] addr_in;
    reg [7:0] power_level;
    reg [255:0] encryption_key;
    reg HWRITE;

    // Outputs
    wire [127:0] encrypted_addr;
    wire [1:0] addr_width;
    wire HREADY;
    wire [63:0] HADDR;
    wire [2:0] HSIZE;
    wire HWRITE_OUT;

    // Clock Generation (50MHz)
    always #10 clk = ~clk; 

    // DUT Instance
    secure_adaptive_bus dut (
        .clk(clk),
        .rst(rst),
        .addr_in(addr_in),
        .power_level(power_level),
        .encryption_key(encryption_key),
        .HWRITE(HWRITE),
        .encrypted_addr(encrypted_addr),
        .addr_width(addr_width),
        .HREADY(HREADY),
        .HADDR(HADDR),
        .HSIZE(HSIZE),
        .HWRITE_OUT(HWRITE_OUT)
    );

    // Test Sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        addr_in = 64'h0000_1234_5678_ABCD;
        power_level = 8'd100; // Balanced Mode (32-bit)
        encryption_key = 256'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
        HWRITE = 1'b0;

        // Reset Pulse
        #20 rst = 0;
        #20 rst = 1;
        #20 rst = 0;

        // Test Case 1: Default 32-bit Mode
        $display("Test Case 1: Default 32-bit Mode");
        #50;
        $display("ADDR_WIDTH: %b | Encrypted Addr: %h | HADDR: %h", addr_width, encrypted_addr, HADDR);

        // Test Case 2: Switch to 64-bit Mode
        $display("Test Case 2: Switching to 64-bit Mode");
        power_level = 8'd200; // High Performance
        #50;
        $display("ADDR_WIDTH: %b | Encrypted Addr: %h | HADDR: %h", addr_width, encrypted_addr, HADDR);

        // Test Case 3: Switch to 16-bit Mode
        $display("Test Case 3: Switching to 16-bit Mode");
        power_level = 8'd30; // Low Power
        #50;
        $display("ADDR_WIDTH: %b | Encrypted Addr: %h | HADDR: %h", addr_width, encrypted_addr, HADDR);

        // Test Case 4: AMBA Bus Write Transaction
        $display("Test Case 4: AMBA Bus Write");
        HWRITE = 1'b1;
        #50;
        $display("HWRITE_OUT: %b | HADDR: %h | HSIZE: %b", HWRITE_OUT, HADDR, HSIZE);

        // Finish Simulation
        #100;
        $display("Simulation Completed!");
        $finish;
    end

endmodule
