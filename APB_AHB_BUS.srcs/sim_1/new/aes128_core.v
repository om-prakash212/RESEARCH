`timescale 1ns/ 1ps

module aes128_core (
    input wire clk,
    input wire [127:0] key,
    input wire [127:0] data_in,
    output reg [127:0] data_out
);
    // Internal signals
    reg [127:0] state;
    reg [127:0] round_keys [0:10]; // 11 round keys for AES-128
    integer round;

    // Key Expansion
    task key_expansion;
        input [127:0] key;
        reg [31:0] temp;
        integer i;
        begin
            round_keys[0] = key; // First round key is the original key
            for (i = 1; i <= 10; i = i + 1) begin
                temp = round_keys[i-1][31:0];
                temp = {temp[23:0], temp[31:24]}; // RotWord
                temp = {sbox(temp[31:24]), sbox(temp[23:16]), sbox(temp[15:8]), sbox(temp[7:0])}; // SubWord
                temp = temp ^ rcon(i); // XOR with Rcon
                round_keys[i] = round_keys[i-1] ^ {temp, 96'b0};
            end
        end
    endtask

    // AES Round Function
    task aes_round;
        input [127:0] state_in;
        input [127:0] round_key;
        output [127:0] state_out;
        begin
            state_out = state_in ^ round_key; // AddRoundKey
            state_out = sub_bytes(state_out); // SubBytes
            state_out = shift_rows(state_out); // ShiftRows
            state_out = mix_columns(state_out); // MixColumns
        end
    endtask

    // SubBytes Transformation
    function [127:0] sub_bytes;
    input [127:0] data;
    begin
        // Unroll the loop manually
        sub_bytes[7:0] = sbox(data[7:0]);
        sub_bytes[15:8] = sbox(data[15:8]);
        sub_bytes[23:16] = sbox(data[23:16]);
        sub_bytes[31:24] = sbox(data[31:24]);
        sub_bytes[39:32] = sbox(data[39:32]);
        sub_bytes[47:40] = sbox(data[47:40]);
        sub_bytes[55:48] = sbox(data[55:48]);
        sub_bytes[63:56] = sbox(data[63:56]);
        sub_bytes[71:64] = sbox(data[71:64]);
        sub_bytes[79:72] = sbox(data[79:72]);
        sub_bytes[87:80] = sbox(data[87:80]);
        sub_bytes[95:88] = sbox(data[95:88]);
        sub_bytes[103:96] = sbox(data[103:96]);
        sub_bytes[111:104] = sbox(data[111:104]);
        sub_bytes[119:112] = sbox(data[119:112]);
        sub_bytes[127:120] = sbox(data[127:120]);
    end
endfunction

    // ShiftRows Transformation
    function [127:0] shift_rows;
        input [127:0] data;
        begin
            shift_rows = {
                data[127:120], data[87:80], data[47:40], data[7:0],
                data[95:88], data[55:48], data[15:8], data[103:96],
                data[63:56], data[23:16], data[111:104], data[71:64],
                data[31:24], data[119:112], data[79:72], data[39:32]
            };
        end
    endfunction

    // MixColumns Transformation
    function [127:0] mix_columns;
    input [127:0] data;
    reg [7:0] a, b, c, d;
    begin
        // Column 0
        a = data[31:24];
        b = data[23:16];
        c = data[15:8];
        d = data[7:0];
        mix_columns[31:24] = gmul(a, 2) ^ gmul(b, 3) ^ c ^ d;
        mix_columns[23:16] = a ^ gmul(b, 2) ^ gmul(c, 3) ^ d;
        mix_columns[15:8] = a ^ b ^ gmul(c, 2) ^ gmul(d, 3);
        mix_columns[7:0] = gmul(a, 3) ^ b ^ c ^ gmul(d, 2);

        // Column 1
        a = data[63:56];
        b = data[55:48];
        c = data[47:40];
        d = data[39:32];
        mix_columns[63:56] = gmul(a, 2) ^ gmul(b, 3) ^ c ^ d;
        mix_columns[55:48] = a ^ gmul(b, 2) ^ gmul(c, 3) ^ d;
        mix_columns[47:40] = a ^ b ^ gmul(c, 2) ^ gmul(d, 3);
        mix_columns[39:32] = gmul(a, 3) ^ b ^ c ^ gmul(d, 2);

        // Column 2
        a = data[95:88];
        b = data[87:80];
        c = data[79:72];
        d = data[71:64];
        mix_columns[95:88] = gmul(a, 2) ^ gmul(b, 3) ^ c ^ d;
        mix_columns[87:80] = a ^ gmul(b, 2) ^ gmul(c, 3) ^ d;
        mix_columns[79:72] = a ^ b ^ gmul(c, 2) ^ gmul(d, 3);
        mix_columns[71:64] = gmul(a, 3) ^ b ^ c ^ gmul(d, 2);

        // Column 3
        a = data[127:120];
        b = data[119:112];
        c = data[111:104];
        d = data[103:96];
        mix_columns[127:120] = gmul(a, 2) ^ gmul(b, 3) ^ c ^ d;
        mix_columns[119:112] = a ^ gmul(b, 2) ^ gmul(c, 3) ^ d;
        mix_columns[111:104] = a ^ b ^ gmul(c, 2) ^ gmul(d, 3);
        mix_columns[103:96] = gmul(a, 3) ^ b ^ c ^ gmul(d, 2);
    end
endfunction
    

    // Galois Field Multiplication
    function [7:0] gmul;
        input [7:0] a;
        input [7:0] b;
        begin
            case (b)
                2: gmul = (a << 1) ^ ((a[7]) ? 8'h1B : 8'h00);
                3: gmul = (a << 1) ^ ((a[7]) ? 8'h1B : 8'h00) ^ a;
                default: gmul = 8'h00;
            endcase
        end
    endfunction

    // S-box Lookup Table
    function [7:0] sbox;
        input [7:0] byte;
        reg [7:0] sbox_table [0:255];
        begin
            // Initialize S-box table explicitly
            sbox_table[8'h00] = 8'h63; sbox_table[8'h01] = 8'h7C; sbox_table[8'h02] = 8'h77; sbox_table[8'h03] = 8'h7B;
            sbox_table[8'h04] = 8'hF2; sbox_table[8'h05] = 8'h6B; sbox_table[8'h06] = 8'h6F; sbox_table[8'h07] = 8'hC5;
            sbox_table[8'h08] = 8'h30; sbox_table[8'h09] = 8'h01; sbox_table[8'h0A] = 8'h67; sbox_table[8'h0B] = 8'h2B;
            sbox_table[8'h0C] = 8'hFE; sbox_table[8'h0D] = 8'hD7; sbox_table[8'h0E] = 8'hAB; sbox_table[8'h0F] = 8'h76;
            // Continue initializing all 256 values...
            sbox_table[8'hFF] = 8'h16; // Last value
            sbox = sbox_table[byte];
        end
    endfunction

    // Rcon Lookup Table
       function [7:0] rcon;
        input integer round;
        reg [7:0] rcon_table [1:10]; // Index from 1 to 10
        begin
            rcon_table[1] = 8'h01;
            rcon_table[2] = 8'h02;
            rcon_table[3] = 8'h04;
            rcon_table[4] = 8'h08;
            rcon_table[5] = 8'h10;
            rcon_table[6] = 8'h20;
            rcon_table[7] = 8'h40;
            rcon_table[8] = 8'h80;
            rcon_table[9] = 8'h1B;
            rcon_table[10] = 8'h36;
            rcon = rcon_table[round];
        end
    endfunction

    // Main Encryption Process
    always @(posedge clk) begin
        // Key Expansion
        key_expansion(key);

        // Initial AddRoundKey
        state = data_in ^ round_keys[0];

        // 9 Main Rounds
        for (round = 1; round <= 9; round = round + 1) begin
            aes_round(state, round_keys[round], state);
        end

        // Final Round (No MixColumns)
        state = sub_bytes(state);
        state = shift_rows(state);
        state = state ^ round_keys[10];

        // Output
        data_out = state;
    end
endmodule