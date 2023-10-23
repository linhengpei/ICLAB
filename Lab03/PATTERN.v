`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"
`include "../00_TESTBED/pseudo_SD.v"

module PATTERN(
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

/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;
output reg        direction;
output reg [12:0] addr_dram;
output reg [15:0] addr_sd;

/* Output for pattern */
input        out_valid;
input  [7:0] out_data;

// DRAM Signals
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output reg AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output reg W_READY;
// write response channel
output reg B_VALID;
output reg [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output reg AR_READY;
// read data channel
output reg [63:0] R_DATA;
output reg R_VALID;
output reg [1:0] R_RESP;
input R_READY;

// SD Signals
output MISO;
input MOSI;

real CYCLE = `CYCLE_TIME;
integer pat_read;
integer PAT_NUM;
integer total_latency, latency;
integer i_pat;

reg [20:0]test [20:0];

reg        direction_temp;
reg [12:0] addr_dram_temp;
reg [15:0] addr_sd_temp;

reg [63:0] Dram_target;
reg [63:0] SD_target;
reg [10:0] counter ; // test

reg [3:0]out_num;
reg [63:0] gold_ans;
reg reset_done;
integer a,b,c,d,e,f,t;
initial
    clk = 0;
always #(CYCLE/2.0) clk = ~clk; // clk

always@(negedge clk) begin
    if( ( out_valid === 0 ) && ( out_data !== 0  ) ) begin
        YOU_FAIL_task;
        $display("*                                                                       *");
        $display("*                         SPEC MAIN-2 FAIL                              *");
        $display("*                                                                       *");
        $finish;
    end
end

initial begin
    pat_read = $fopen("../00_TESTBED/Input.txt", "r");
    reset_done = 0;

    reset_signal_task;
    reset_done = 1;
    i_pat = 0;
    total_latency = 0;
    $fscanf(pat_read, "%d", PAT_NUM);
    counter = 0;
    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin

        input_task;
        wait_out_valid_task;
        check_ans_task;

        total_latency = total_latency + latency;
        $display("PASS PATTERN NO.%4d", i_pat);
    end
    $fclose(pat_read);
    $writememh("../00_TESTBED/DRAM_final.dat", u_DRAM.DRAM);
    $writememh("../00_TESTBED/SD_final.dat", u_SD.SD);
    //gold;
    //check;
    YOU_PASS_task;

end

task reset_signal_task;
    reg condition;
    begin
        rst_n = 1'b1;
        in_valid = 1'b0;
        direction = 1'bx;
        addr_dram = 13'bx;
        addr_sd = 16'bx;

        force clk = 1'b0;
        rst_n = 1'b0;
        #(100); // 100ns
        condition = (( out_valid !== 0 ) || ( out_data !== 0 ) || ( AW_ADDR !== 0) || ( AW_VALID !== 0 ) ||
                     ( W_VALID !== 0 ) || ( W_DATA !== 0 ) || ( B_READY !== 0 ) || ( AR_ADDR !== 0 ) ||
                     ( AR_VALID !== 0 ) || ( R_READY !== 0 ) || ( MOSI !== 1 ) );

        if( condition ) begin
            YOU_FAIL_task;
            $display("*                                                                       *");
            $display("*                         SPEC MAIN-1 FAIL                              *");
            $display("*                                                                       *");
            $finish;
        end
        rst_n = 1'b1;
        release clk;
    end
endtask

task input_task;
    begin
        if(out_valid !== 1) begin

            t = $urandom_range(2, 4); // The next input
            repeat(t) @(negedge clk);

            in_valid = 1'b1;
            a = $fscanf(pat_read, "%d %d %d", direction , addr_dram , addr_sd);
            direction_temp = direction;
            addr_dram_temp = addr_dram;
            addr_sd_temp = addr_sd;

            @(negedge clk);
            in_valid = 1'b0;
            direction = 1'bx;
            addr_dram = 13'bx;
            addr_sd = 16'bx;
        end
    end
endtask

task wait_out_valid_task;
    begin
        latency = 0;
        while (out_valid !== 1'b1) begin
            if(latency == 10000) begin
                YOU_FAIL_task;
                $display("*                                                                       *");
                $display("*                         SPEC MAIN-3 FAIL                              *");
                $display("*                                                                       *");
                $finish;
            end
            latency = latency + 1;
            @(negedge clk);
        end
    end
endtask


task check_ans_task;
    begin
        out_num = 0;

        if(direction_temp === 1)
            gold_ans =  u_SD.SD[addr_sd_temp];
        else
            gold_ans =  u_DRAM.DRAM[addr_dram_temp];

        Dram_target = u_DRAM.DRAM[addr_dram_temp];
        SD_target = u_SD.SD[addr_sd_temp];

        counter = counter + 1 ;

        while((out_valid === 1)) begin

            if(u_DRAM.DRAM[addr_dram_temp] != u_SD.SD[addr_sd_temp])
                SPEC_MAIN_6;

            if(out_num > 8)
                SPEC_MAIN_4 ;


            if(out_data !== gold_ans[63:56]) begin
                YOU_FAIL_task;
                $display("*                                                                       *");
                $display("*                         SPEC MAIN-5 FAIL                              *");
                $display("*                                                                       *");
                $display("True address is : %d",addr_dram_temp);
                $display("your answer is : %d",out_data);
                $display("gold data_out is : %d",gold_ans[63:56]);
                $display("\n\n");
                $finish;
            end
            else begin
                out_num = out_num + 1;
                gold_ans =  {gold_ans[55:0],8'b0};
            end
            @(negedge clk);
        end

        if(out_num != 8)
            SPEC_MAIN_4 ;
    end
endtask

task SPEC_MAIN_4 ;
    YOU_FAIL_task;
    $display("*                                                                       *");
    $display("*                         SPEC MAIN-4 FAIL                              *");
    $display("*                                                                       *");
    $finish;
endtask


task YOU_PASS_task;
    begin
        $display("*************************************************************************");
        $display("*                         Congratulations!                              *");
        $display("*                Your execution cycles = %5d cycles                  *", total_latency);
        $display("*                Your clock period = %.1f ns                            *", CYCLE);
        $display("*                Total Latency = %.1f ns                          *", total_latency*CYCLE);
        $display("*************************************************************************");
        $finish;
    end
endtask

task YOU_FAIL_task;
    begin
        $display("*                              FAIL!                                    *");
        $display("*                    Error message from PATTERN.v                       *");
    end
endtask

task  SPEC_MAIN_6;
    YOU_FAIL_task;
    $display("*                                                                       *");
    $display("*                         SPEC MAIN-6 FAIL                              *");
    $display("*                                                                       *");
    $finish;
endtask

task gold;
    parameter SD_p = "../00_TESTBED/SD_init.dat";
    parameter DRAM_p = "../00_TESTBED/DRAM_init.dat";
    reg [63:0] SD_init [0:65535];
    reg [63:0] DRAM_init [0:8191];
    integer pat_read_test;
    integer PAT_NUM_test;
    reg [63:0] dram_addr ;
    reg [63:0] sd_addr   ;
    reg d;
    integer i;
    begin     //check final
        $readmemh(SD_p, SD_init);
        $readmemh(DRAM_p, DRAM_init);
        pat_read_test = $fopen("../00_TESTBED/Input.txt", "r");
        $fscanf(pat_read_test, "%d", PAT_NUM);

        for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
            a = $fscanf(pat_read, "%d %d %d", d , dram_addr , sd_addr);
            if(d === 1) begin
                DRAM_init[dram_addr] =  SD_init[ sd_addr];
            end
            else begin
                SD_init[ sd_addr] =  DRAM_init[dram_addr] ;
            end
        end
        /*
                for (i = 0; i < 8192; i = i + 1) begin
                    if(DRAM_init[i] !== u_DRAM.DRAM[i]) begin
                        $display(" DRAM result wrong !!!  %d",i);
                        $finish;
                    end
                end
                for (i = 0; i < 65535; i = i + 1) begin
                    if(SD_init[i] !== u_SD.SD[i]) begin
                        $display(" SD result wrong !!!  %d",i);
                        $finish;
                    end
                end
        */
        $fclose(pat_read_test);

        $writememh("../00_TESTBED/DRAM_golden.dat", DRAM_init);
        $writememh("../00_TESTBED/SD_golden.dat", SD_init);
    end
endtask

task check;
    parameter SD_p = "../00_TESTBED/SD_golden.dat";
    parameter DRAM_p = "../00_TESTBED/DRAM_golden.dat";
    reg [63:0] SD_answer [0:65535];
    reg [63:0] DRAM_answer [0:8191];
    integer i;
    begin     //check final
        $readmemh(SD_p, SD_answer);
        $readmemh(DRAM_p, DRAM_answer);

        for (i = 0; i < 8192; i = i + 1) begin
            if(DRAM_answer[i] !== u_DRAM.DRAM[i]) begin
                $display(" DRAM result wrong !!!  %d",i);
                $finish;
            end
        end
        for (i = 0; i < 65535; i = i + 1) begin
            if(SD_answer[i] !== u_SD.SD[i]) begin
                $display(" SD result wrong !!!  %d",i);
                $finish;
            end
        end
        $display(" \n\n ALL data is corrrect ! \n\n");
    end
endtask

pseudo_DRAM u_DRAM (
                .clk(clk),
                .rst_n(rst_n),
                // write address channel
                .AW_ADDR(AW_ADDR),
                .AW_VALID(AW_VALID),
                .AW_READY(AW_READY),
                // write data channel
                .W_VALID(W_VALID),
                .W_DATA(W_DATA),
                .W_READY(W_READY),
                // write response channel
                .B_VALID(B_VALID),
                .B_RESP(B_RESP),
                .B_READY(B_READY),
                // read address channel
                .AR_ADDR(AR_ADDR),
                .AR_VALID(AR_VALID),
                .AR_READY(AR_READY),
                // read data channel
                .R_DATA(R_DATA),
                .R_VALID(R_VALID),
                .R_RESP(R_RESP),
                .R_READY(R_READY)
            );

pseudo_SD u_SD (
              .clk(clk),
              .MOSI(MOSI),
              .MISO(MISO)
          );

endmodule
