//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Ting-Yu Chang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : BRIDGE_encrypted.v
//   Module Name : BRIDGE
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module BRIDGE(
           // Input Signals
           clk,
           rst_n,
           in_valid,
           direction,
           addr_dram,
           addr_sd,
           // Output Signals
           out_valid,
           out_data,
           // DRAM Signals
           AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
           AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
           // SD Signals
           MISO,
           MOSI
       );

// Input Signals
input clk, rst_n;
input in_valid;
input direction;
input [12:0] addr_dram;
input [15:0] addr_sd;

// Output Signals
output reg out_valid;
output reg [7:0] out_data;

// DRAM Signals
// write address channel
output reg [31:0] AW_ADDR;
output reg AW_VALID;
input AW_READY;
// write data channel
output reg W_VALID;
output reg [63:0] W_DATA;
input W_READY;
// write response channel
input B_VALID;
input [1:0] B_RESP;
output reg B_READY;
// read address channel
output reg [31:0] AR_ADDR;
output reg AR_VALID;
input AR_READY;
// read data channel
input [63:0] R_DATA;
input R_VALID;
input [1:0] R_RESP;
output reg R_READY;

// SD Signals
input MISO;
output reg MOSI;

reg [31:0]counter;
reg dir;
reg [31:0] addr_d;
reg [31:0] addr_s;

reg [63:0] data;
reg [47:0] Write_command_sd;
reg [87:0] Write_data_sd;
reg [47:0] Read_command_sd;
reg [87:0] Read_data_sd;
wire [39:0] CRC7_input;
assign CRC7_input = (dir == 1 ) ? {2'b01,6'b010001,addr_s} : {2'b01,6'b011000,addr_s};

reg [4:0] c_state;
parameter Load           = 5'd0,
          Read_dram1     = 5'd1,
          Read_dram2     = 5'd2,
          W_prepare        = 5'd3,
          Write_sd1      = 5'd4,
          Write_respond1 = 5'd5,
          Write_respond2 = 5'd6,
          Wait_8_clk     = 5'd7,
          Write_sd2      = 5'd8,
          Wait_respond   = 5'd9,
          Data_respond   = 5'd10,
          Wait_out       = 5'd11,

          R_prepare      = 5'd12,
          Read_sd1       = 5'd13,
          Read_respond1  = 5'd14,
          Read_respond2  = 5'd15,
          Wait_data      = 5'd16,
          Read_sd2       = 5'd17,
          Read_sd3       = 5'd18,
          Write_dram1    = 5'd19,
          Write_dram2    = 5'd20,
          Write_dram3    = 5'd21,

          Out            = 5'd22;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;

        out_data <= 0 ; //test
        // DRAM Signals
        // write address channel
        AW_ADDR <= 0;
        AW_VALID <= 0;
        // write data channel
        W_VALID <= 0;
        W_DATA <= 0;
        // write response channel
        B_READY <= 0;
        // read address channel
        AR_ADDR <= 0;
        AR_VALID <= 0;
        // read data channel
        R_READY <= 0;
        // SD Signals
        MOSI <= 1;

        counter <= 0;
        c_state <= Load;
    end
    else begin
        case(c_state)
            Load : begin
                counter <= 0;
                if(in_valid) begin
                    dir <= direction;
                    addr_d <= addr_dram;
                    addr_s <= addr_sd;

                    if(direction == 1)
                        c_state <= R_prepare ; //  sd to dram
                    else
                        c_state <= Read_dram1; // dram to sd
                end
            end
            Read_dram1 : begin
                if(AR_READY  == 0) begin
                    AR_ADDR <= addr_d ;
                    AR_VALID <= 1;
                end
                else begin  // AR_READY == 1
                    AR_ADDR <= 0 ;
                    AR_VALID <= 0;
                    R_READY <= 1;

                    c_state <=  Read_dram2;
                end
            end
            Read_dram2 : begin
                if(R_VALID == 0) begin
                    R_READY <= 1;
                end
                else begin
                    R_READY <= 0;
                    data <= R_DATA;

                    c_state <=  W_prepare;
                end
            end
            W_prepare : begin
                counter <= 47;
                Write_command_sd <= { 2'b01 , 6'b011000 , addr_s , CRC7(CRC7_input) , 1'b1};
                c_state <=  Write_sd1;
            end
            Write_sd1 : begin
                MOSI <= Write_command_sd[counter];
                counter <= counter - 1;
                if(counter == 0) begin
                    c_state <=   Write_respond1 ;
                    counter <= 0;
                end
            end
            Write_respond1 : begin
                if(MISO == 0)
                    c_state <= Write_respond2 ;
            end
            Write_respond2 : begin
                if(MISO == 1)
                    c_state <= Wait_8_clk ;
            end
            Wait_8_clk : begin
                counter <= counter + 1;
                Write_data_sd <= {8'hFE,data,CRC16_CCITT(data)};
                if(counter == 13) begin
                    counter <= 87;
                    c_state <=  Write_sd2;
                end
            end

            Write_sd2 : begin // write_data
                MOSI <= Write_data_sd[counter];
                counter <= counter - 1;
                if(counter == 0) begin
                    c_state <=  Wait_respond;
                    counter <= 0;
                end
            end
            Wait_respond : begin
                MOSI <= 1;
                if(MISO == 0) begin
                    c_state <= Data_respond;
                    counter <= 1;
                end
            end
            Data_respond : begin

                counter <= counter + 1;
                if(counter == 8) begin

                    counter <= 0;
                    c_state <= Wait_out;
                    //c_state <= Out;
                end
            end
            Wait_out : begin
                if(MISO == 1) begin
                    c_state <= Out;
                end

            end

            R_prepare: begin
                counter <= 47;
                Read_command_sd <= { 2'b01 , 6'b010001 , addr_s , CRC7(CRC7_input) , 1'b1};
                c_state <= Read_sd1;
            end
            Read_sd1: begin
                MOSI <= Read_command_sd[counter];
                counter <= counter - 1;
                if(counter == 0) begin
                    c_state <=   Read_respond1 ;
                    counter <= 0;
                end
            end
            Read_respond1 : begin
                if(MISO == 0)
                    c_state <=  Read_respond2 ;
            end
            Read_respond2 : begin// respond end
                if(MISO == 1) begin
                    c_state <= Wait_data ;
                end
            end
            Wait_data : begin
                counter <= 79;
                Read_data_sd[87:80] <= 8'hFE;
                if(MISO == 0) begin
                    c_state <= Read_sd2 ;
                end
            end
            Read_sd2: begin
                counter <= counter - 1;
                Read_data_sd[counter] <= MISO;
                if(counter == 0) begin
                    c_state <=   Write_dram1 ;
                    counter <= 0;
                end
            end

            Write_dram1: begin //write dram address
                if(AW_READY == 0) begin
                    AW_ADDR <= addr_d;
                    AW_VALID <= 1;
                end
                else begin
                    AW_ADDR <= 0;
                    AW_VALID <= 0;

                    W_DATA <=  Read_data_sd[79:16];
                    W_VALID <= 1;

                    data <= Read_data_sd[79:16];
                    c_state <= Write_dram2;
                end
            end
            Write_dram2: begin //write dram data
                if(W_READY == 1) begin
                    B_READY <= 1;

                    W_DATA <= 0;
                    W_VALID <= 0;
                    c_state <= Write_dram3;
                end
            end
            Write_dram3: begin //write dram data
                if(B_VALID == 1) begin
                    B_READY <= 0;
                    c_state <= Out;
                end
            end
            Out: begin

                out_data <= data[63:56];
                data <= {data[55:0] , 8'b0};

                if(counter != 8) begin
                    out_valid <= 1 ;
                    counter <= counter + 1;
                end
                else begin
                    out_valid <= 1'b0;
                    c_state <= Load;
                end
            end
        endcase
    end
end


function automatic [6:0] CRC7;  // Return 7-bit result
    input [39:0] data;  // 40-bit data input
    reg [6:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 7'h9;  // x^7 + x^3 + 1

    begin
        crc = 7'd0;
        for (i = 0; i < 40; i = i + 1) begin
            data_in = data[39-i];
            data_out = crc[6];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC7 = crc;
    end
endfunction

function automatic [15:0] CRC16_CCITT;  // Try to implement CRC-16-CCITT function by yourself.
    input [63:0] data;  // 64-bit data input
    reg [15:0] crc;     // 16-bit data output
    integer i;
    reg data_in, data_out;
    parameter polynomial = 16'h1021;  // x^16 + x^12 + x^5 + 1

    begin
        crc = 16'd0;
        for (i = 0; i < 64; i = i + 1) begin
            data_in = data[63-i];
            data_out = crc[15];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC16_CCITT = crc;
    end
endfunction

endmodule

