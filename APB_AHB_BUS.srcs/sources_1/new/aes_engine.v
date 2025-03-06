`timescale 1ns/1ps

module aes_engine (
    input wire clk,
    input wire rst,
    input wire [127:0] plain_addr,
    input wire [255:0] key,
    output wire [127:0] encrypted_addr
);

    aes_core aes_inst (
        .clk(clk),
        .reset_n(~rst),
        .encdec(1'b1),   // 1 = Encrypt
        .init(1'b1),
        .next(1'b1),
        .ready(),
        .key(key),
        .keylen(1'b1),   // 256-bit key
        .block(plain_addr),
        .result(encrypted_addr),
        .result_valid()
    );

endmodule
