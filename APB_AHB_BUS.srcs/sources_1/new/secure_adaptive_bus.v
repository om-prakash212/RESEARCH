`timescale 1ns/1ps

module secure_adaptive_bus (
    input wire clk,
    input wire rst,
    input wire [63:0] addr_in,         // Input address
    input wire [7:0] power_level,      // Power level for dynamic scaling
    input wire [255:0] encryption_key, // AES encryption key (256-bit)
    input wire HWRITE,                 // Write signal
    output wire [127:0] encrypted_addr,// Encrypted address output
    output wire [1:0] addr_width,      // Current address width mode
    output wire HREADY,
    output wire [63:0] HADDR,
    output wire [2:0] HSIZE,
    output wire HWRITE_OUT
);

    wire [1:0] addr_width_sel;
    wire [63:0] adjusted_addr;
    wire [127:0] encrypted_data;

    // Power Manager - Determines Address Width
    power_manager power_ctrl (
        .clk(clk),
        .rst(rst),
        .power_level(power_level),
        .addr_width_sel(addr_width_sel)
    );

    // Address Bus Controller - Adjusts Address Width
    bus_width_controller bus_ctrl (
        .clk(clk),
        .reset(rst),
        .width_sel(addr_width_sel),
        .addr_in(addr_in),
        .addr_out(adjusted_addr),
        .current_width(addr_width)
    );

    // AES Engine - Encrypts Adjusted Address
    aes_engine encryptor (
        .clk(clk),
        .rst(rst),
        .plain_addr({64'b0, adjusted_addr}), // Zero-pad lower bits
        .key(encryption_key),
        .encrypted_addr(encrypted_data)
    );

    assign encrypted_addr = encrypted_data;

    // AMBA Interface - Handles Bus Transactions
    amba_interface amba_intf (
        .HCLK(clk),
        .HRESETn(~rst),
        .current_width(addr_width),
        .encrypted_addr(encrypted_data[63:0]), // Send lower 64-bits
        .HWRITE(HWRITE),
        .VALID(1'b1),
        .HREADY(HREADY),
        .HADDR(HADDR),
        .HSIZE(HSIZE),
        .HWRITE_OUT(HWRITE_OUT)
    );

endmodule
