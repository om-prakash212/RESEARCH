`timescale 1ns/1ps

module amba_interface (
    input wire HCLK,
    input wire HRESETn,
    input wire [1:0] current_width,
    input wire [63:0] encrypted_addr,
    input wire HWRITE,
    input wire VALID,
    output reg HREADY,
    output reg [63:0] HADDR,
    output reg [2:0] HSIZE,
    output reg HWRITE_OUT
);

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        HADDR <= 64'b0;
        HSIZE <= 3'b010; // Default to 32-bit
        HREADY <= 1'b0;
        HWRITE_OUT <= 1'b0;
    end else begin
        if (VALID) begin
            HADDR <= encrypted_addr;
            HWRITE_OUT <= HWRITE;
            case (current_width)
                2'b00: HSIZE <= 3'b000; // 16-bit
                2'b01: HSIZE <= 3'b010; // 32-bit
                2'b10: HSIZE <= 3'b011; // 64-bit
                default: HSIZE <= 3'b010;
            endcase
            HREADY <= 1'b1;
        end else begin
            HREADY <= 1'b0;
        end
    end
end

endmodule
