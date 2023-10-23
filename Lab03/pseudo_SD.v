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
//   File Name   : pseudo_SD.v
//   Module Name : pseudo_SD
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module pseudo_SD (
           clk,
           MOSI,
           MISO
       );

input clk;
input MOSI;
output reg MISO;

parameter SD_p_r = "../00_TESTBED/SD_init.dat";

reg [63:0] SD [0:65535];
initial
    $readmemh(SD_p_r, SD);

reg [47:0] command;
reg [15:0] addr;
reg [87:0] data_w;
reg [87:0] data_r;
reg [63:0] data_sd;
reg [ 7:0] respond;


reg  [6:0] CRC7_test;
reg [15:0] CRC16_test;


integer PAT_NUM;
integer pat_read;
integer i_pat;
integer clk_cnt;
integer i , t;
reg write ;

initial begin
    pat_read = $fopen("../00_TESTBED/Input.txt", "r");
    $fscanf(pat_read, "%d", PAT_NUM);

    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
        clk_cnt = 0;
        MISO = 1;

        @(negedge MOSI);
        @(negedge clk);
        for(i = 47; i >= 0 ;i = i - 1 ) begin //load command
            command[i] = MOSI;
            @(negedge clk);
        end
        chech_sd1_task;

        write = ( command[45:40] === 6'b011000)? 1 : 0 ; // write mode

        addr = command[39:8];

        t = $urandom_range(0,8);
        repeat(8 * t) @(negedge clk); //wait t  Units ( 1 Unit = 8 cycles)

        MISO = 0;
        repeat(8) @(negedge clk); // respond 8'b0
        MISO = 1 ;

        if(write)
            write_sd_task;
        else
            read_sd_task;
    end
    $fclose(pat_read);
end



task write_sd_task;  //write mode
    respond = 8'b00000101;
    begin
        data_sd = u_DRAM.DRAM[addr];
        //
        while( MOSI !== 0) begin
            clk_cnt =  clk_cnt  + 1;
            @(negedge clk);
        end

        if((clk_cnt +1 ) %8 !== 0  || clk_cnt < 15)
            sd5_fail_task;

        data_w[87:81] = 7'b1111111;
        for(i = 80; i >= 0 ;i = i - 1 ) begin // load data
            data_w[i] = MOSI;
            @(negedge clk);
        end

        check_CRC16_task;   // check CRC16_CCITT

        for(i = 7; i >= 0 ;i = i - 1 ) begin  // respond
            MISO = respond[i];
            @(negedge clk);
        end

        SD[addr[15:0]] = data_w[79:16]; // write in SD

        MISO = 0 ;
        t = $urandom_range(0,32);
        repeat(8 * t) @(negedge clk); //wait t  Units ( 1 Unit = 8 cycles)
        MISO = 1 ;


    end
endtask

task read_sd_task; //read mode
    t = $urandom_range(1,32);
    repeat(8 * t) @(negedge clk); //wait t  Units ( 1 Unit = 8 cycles)
    data_sd = SD[addr];
    data_r[87:80] = 8'b11111110;
    data_r[79:16] =  data_sd;
    data_r[15:0] = CRC16_CCITT(data_sd);
    for(i = 87; i >= 0 ;i = i - 1 ) begin // load data
        MISO <= data_r[i];
        @(negedge clk);
    end
endtask


task  chech_sd1_task;

    if(command[47:46] != 2'b01)
        sd1_fail_task;

    if( ( command[45:40] != 6'd17 ) && ( command[45:40] != 6'd24) )
        sd1_fail_task;

    if(command[39:24] != 16'b0)
        sd2_fail_task;

    if(command[0] != 1'b1)
        sd1_fail_task;

    CRC7_test =  CRC7(command[47:8]);    //check crc-7
    check_CRC7_task;
endtask

task  sd1_fail_task;
    YOU_FAIL_task;
    $display("*                                                                       *");
    $display("*                          SPEC SD-1 FAIL                               *");
    $display("*                                                                       *");
    $finish;
endtask

task  sd2_fail_task;
    YOU_FAIL_task;
    $display("*                                                                       *");
    $display("*                          SPEC SD-2 FAIL                               *");
    $display("*                                                                       *");
    $finish;
endtask

task check_CRC7_task;
    if( CRC7_test !== command[7:1]) begin
        YOU_FAIL_task;
        $display("*                                                                       *");
        $display("*                          SPEC SD-3 FAIL                               *");
        $display("*                                                                       *");
        $finish;
    end
endtask

task check_CRC16_task;
    CRC16_test =  CRC16_CCITT(data_w[79:16]);
    if( CRC16_test !== data_w[15:0]) begin
        YOU_FAIL_task;
        $display("*                                                                       *");
        $display("*                          SPEC SD-4 FAIL                               *");
        $display("*                                                                       *");
        $finish;
    end
endtask

task  sd5_fail_task;
    YOU_FAIL_task;
    $display("*                                                                       *");
    $display("*                          SPEC SD-5 FAIL                               *");
    $display("*                                                                       *");
    $finish;
endtask



task YOU_FAIL_task;
    begin
        $display("*                              FAIL!                                    *");
        $display("*                 Error message from pseudo_SD.v                        *");
    end
endtask

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
