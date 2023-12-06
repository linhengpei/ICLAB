module CLK_1_MODULE (
           clk,
           rst_n,
           in_valid,
           seed_in,
           out_idle,
           out_valid,
           seed_out,

           clk1_handshake_flag1,
           clk1_handshake_flag2,
           clk1_handshake_flag3,
           clk1_handshake_flag4
       );

input clk;
input rst_n;
input in_valid;
input [31:0] seed_in;
input out_idle; // sidle
output reg out_valid;
output reg [31:0] seed_out; // connect to handshake din

// You can change the input / output of the custom flag ports
output reg clk1_handshake_flag1;
output reg clk1_handshake_flag2;
input      clk1_handshake_flag3;
input      clk1_handshake_flag4;

reg  [2:0] state;
reg [31:0] seed_temp;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= 0;
        out_valid <= 0 ;
        seed_out <= 0;

    end
    else begin
        case(state)
            0: begin
                if(in_valid) begin
                    seed_temp <= seed_in;
                    state <= 1;
                end
            end
            1: begin
                if(out_idle == 0) begin
                    out_valid <= 1;         //start to transmit
                    seed_out <= seed_temp;
                end
                else begin
                    out_valid <= 0;   //end transmit
                    seed_out <= 0;
                    state <= 0;
                end
            end
        endcase
    end
end


endmodule

    module CLK_2_MODULE (
        clk,
        rst_n,
        in_valid,
        fifo_full,
        seed,
        out_valid,
        rand_num,
        busy,

        handshake_clk2_flag1,
        handshake_clk2_flag2,
        handshake_clk2_flag3,
        handshake_clk2_flag4,

        clk2_fifo_flag1,
        clk2_fifo_flag2,
        clk2_fifo_flag3,
        clk2_fifo_flag4
    );

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output reg  out_valid;
output reg [31:0] rand_num;
output reg busy;

// You can change the input / output of the custom flag ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
output reg handshake_clk2_flag3;
output reg handshake_clk2_flag4;

output clk2_fifo_flag1;
output clk2_fifo_flag2;
input clk2_fifo_flag3; // full
input clk2_fifo_flag4;

reg [2:0] state;
reg [8:0] clk2_cnt;

reg [31:0]last_data;
reg [31:0]last_data2;
reg [31:0]seed_temp;
reg [31:0]next_data;
always@(*) begin
    next_data = seed_temp;
    next_data = next_data ^ (next_data << 13);
    next_data = next_data ^ (next_data >> 17);
    next_data = next_data ^ (next_data <<  5);
end


reg even_full;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= 0;
        clk2_cnt <= 0 ;

        out_valid <= 0 ;
        rand_num  <= 0;
        busy <= 0;

        seed_temp <= 0;
        last_data <= 0;
        last_data2 <= 0;

        even_full <= 0;
    end
    else begin
        case(state)
            0: begin
                even_full <= 0;
                clk2_cnt <= 0;
                if(in_valid == 1) begin // load seed
                    seed_temp <= seed ;
                    busy <= 1 ;
                    state <= 1;
                end
            end
            1: begin
                busy <= 0 ;
                state <= 2;
            end
            //////// full
            2: begin // start calculate
                if(clk2_fifo_flag3 == 0) begin
                    out_valid <= 1;
                    rand_num <= next_data;
                    seed_temp <= next_data;
                    last_data <= rand_num;
                    last_data2 <= last_data ;
                    clk2_cnt <= clk2_cnt + 1 ;
                    if(clk2_cnt == 256) begin// 4.1 to 6  else to 3
                        if( even_full == 0) begin
                            state <= 6;
                            out_valid <= 0 ;
                        end
                        else begin
                            state <= 4;
                            rand_num <=  seed_temp ;
                        end

                    end
                end
                else begin // full need wait
                    seed_temp <= last_data2;

                    even_full <= 1;
                    out_valid <= 0;
                    rand_num <=  last_data2;
                    state <= 3;
                end
            end

            3: begin
                if(clk2_fifo_flag3 == 0) begin
                    state <= 2;
                    clk2_cnt <= clk2_cnt - 2 ;
                end
            end
            ///////////
            4: begin
                state <= 5;
            end
            5: begin
                if(clk2_fifo_flag3 == 0)
                    state <= 6;
            end
            //////////
            6: begin
                if(clk2_fifo_flag3 == 0) begin
                    state <= 0;
                    out_valid <= 0 ;
                end

                clk2_cnt <= 0 ;
                rand_num  <= 0;
                busy <= 0;
                seed_temp <= 0;
            end

        endcase
    end
end

endmodule

    module CLK_3_MODULE (
        clk,
        rst_n,
        fifo_empty,
        fifo_rdata,
        fifo_rinc,
        out_valid,
        rand_num,

        fifo_clk3_flag1,
        fifo_clk3_flag2,
        fifo_clk3_flag3,
        fifo_clk3_flag4
    );

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output reg fifo_rinc;
output reg out_valid;
output reg [31:0] rand_num;

// You can change the input / output of the custom flag ports
output fifo_clk3_flag1;
output fifo_clk3_flag2;
input fifo_clk3_flag3;
input fifo_clk3_flag4;

reg [2:0] state;

reg [8:0] out_cnt;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_cnt <= 0;
        state <= 0;

        fifo_rinc <= 0 ;
        out_valid <= 0 ;
        rand_num  <= 0 ;
    end
    else begin
        case(state)
            0: begin
                //if(fifo_empty == 0) begin // start read data
                if(fifo_clk3_flag3 == 0) begin
                    fifo_rinc <= 1;
                    state <= 1;
                end
            end
            1: begin
                state <= 2;
            end // wait one cycles
            2: begin
                out_cnt <=  out_cnt + 1;

                fifo_rinc <= 1;
                out_valid <= 1;
                rand_num <= fifo_rdata;

                if(out_cnt == 256) begin
                    state <= 3;
                    out_valid <= 0;
                    rand_num <= 0;
                end
            end
            3: begin
                state <= 0;
                out_cnt <= 0;
                fifo_rinc <= 0 ;
                out_valid <= 0 ;
                rand_num  <= 0 ;
            end
        endcase
    end
end

endmodule
