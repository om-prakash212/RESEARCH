`timescale 1ns/1ps

module power_manager (
    input wire clk,
    input wire rst,
    input wire [7:0] power_level,   // Power level indicator (0-255)
    output reg [1:0] addr_width_sel // 00: 16-bit, 01: 32-bit, 10: 64-bit
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        addr_width_sel <= 2'b10; // Default: 64-bit (High Performance)
    end else begin
        if (power_level < 50)
            addr_width_sel <= 2'b00; // 16-bit (Low Power Mode)
        else if (power_level < 150)
            addr_width_sel <= 2'b01; // 32-bit (Balanced Mode)
        else
            addr_width_sel <= 2'b10; // 64-bit (High Performance Mode)
    end
end

endmodule
