`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2025 15:39:08
// Design Name: 
// Module Name: bus_width_controller_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bus_width_controller_tb;
    // Inputs
    reg clk;
    reg reset;
    reg [1:0] width_sel;
    reg [63:0] addr_in;

    // Outputs
    wire [63:0] addr_out;
    wire [1:0] current_width;

    // Instantiate the Unit Under Test (UUT)
    bus_width_controller uut (
        .clk(clk),
        .reset(reset),
        .width_sel(width_sel),
        .addr_in(addr_in),
        .addr_out(addr_out),
        .current_width(current_width)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test Procedure
    initial begin
        // Initialize Inputs
        reset = 1;
        width_sel = 2'b01; // Default 32-bit
        addr_in = 64'h1234_5678_9ABC_DEF0;
        #20; // Wait for 20 time units

        // Release Reset
        reset = 0;
        #10; // Wait for 10 time units

        // Test 16-bit Mode
        width_sel = 2'b00; // 16-bit
        addr_in = 64'h1234_5678_9ABC_DEF0;
        #20; // Wait for 20 time units
        $display("16-bit Mode: addr_out = %h, current_width = %b", addr_out, current_width);

        // Test 32-bit Mode
        width_sel = 2'b01; // 32-bit
        addr_in = 64'h1234_5678_9ABC_DEF0;
        #20; // Wait for 20 time units
        $display("32-bit Mode: addr_out = %h, current_width = %b", addr_out, current_width);

        // Test 64-bit Mode
        width_sel = 2'b10; // 64-bit
        addr_in = 64'h1234_5678_9ABC_DEF0;
        #20; // Wait for 20 time units
        $display("64-bit Mode: addr_out = %h, current_width = %b", addr_out, current_width);

        // Test Reset Condition
        reset = 1;
        #10; // Wait for 10 time units
        $display("Reset Condition: addr_out = %h, current_width = %b", addr_out, current_width);

        // End Simulation
        $stop;
    end

endmodule
