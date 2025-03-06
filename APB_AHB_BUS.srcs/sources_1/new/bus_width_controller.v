`timescale 1ns/1ps

module bus_width_controller(
    input wire clk,
    input wire reset,
    input wire [1:0] width_sel,  // 00:16-bit, 01:32-bit, 10:64-bit
    input wire [63:0] addr_in,
    output reg [63:0] addr_out,
    output reg [1:0] current_width
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_width <= 2'b01; // Default to 32-bit mode
        addr_out <= 64'b0;
    end else begin
        case (width_sel)
            2'b00: addr_out <= {48'b0, addr_in[15:0]}; // 16-bit mode
            2'b01: addr_out <= {32'b0, addr_in[31:0]}; // 32-bit mode
            2'b10: addr_out <= addr_in;                // 64-bit mode
            default: addr_out <= 64'b0;
        endcase
        current_width <= (width_sel == 2'b11) ? 2'b01 : width_sel; // Avoid illegal states
    end
end

endmodule
