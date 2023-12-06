module FIFO_syn #(parameter WIDTH=32, parameter WORDS=64) (
           wclk,
           rclk,
           rst_n,
           winc,
           wdata,
           wfull,
           rinc,
           rdata,
           rempty,

           clk2_fifo_flag1,
           clk2_fifo_flag2,
           clk2_fifo_flag3,
           clk2_fifo_flag4,

           fifo_clk3_flag1,
           fifo_clk3_flag2,
           fifo_clk3_flag3,
           fifo_clk3_flag4
       );

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output rempty;

// You can change the input / output of the custom flag ports
input clk2_fifo_flag1;
input clk2_fifo_flag2;
output reg clk2_fifo_flag3; //used full
output reg clk2_fifo_flag4; //used wfull

input fifo_clk3_flag1;
input fifo_clk3_flag2;
output reg  fifo_clk3_flag3; // empty
output reg fifo_clk3_flag4; // finished

wire [WIDTH-1:0] rdata_q;

// Remember:
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr;
reg [$clog2(WORDS):0] rptr;

reg [6:0] write_address;
reg [6:0] read_address; // binary format
always @(*) begin  // gary code combinatial
    wptr = write_address ^ (write_address >> 1);
    rptr = read_address ^ (read_address >> 1);
end

reg [6:0] wptr_to_r;
reg [6:0] rptr_to_w;

NDFF_BUS_syn #(.WIDTH(7)) ndff1(.D(rptr), .Q(rptr_to_w), .clk(wclk), .rst_n(rst_n));
NDFF_BUS_syn #(.WIDTH(7)) ndff2(.D(wptr), .Q(wptr_to_r), .clk(rclk), .rst_n(rst_n));



// rdata
//  Add one more register stage to rdata
always @(posedge rclk) begin
    if (rinc)
        rdata <= rdata_q;
end

reg [31:0]write_data;
reg WEB1;
wire WEB2;
wire CS1 , CS2;
assign CS2 = 1'b1;
assign WEB2 = 1'b1;
DUAL_64X32X1BM1 u_dual_sram (
                    .CKA(wclk),
                    .CKB(rclk),
                    .WEAN(WEB1),
                    .WEBN(WEB2),
                    .CSA(CS1),
                    .CSB(CS2),
                    .OEA(1'b1),
                    .OEB(1'b1),
                    .A0( write_address[0]),
                    .A1( write_address[1]),
                    .A2( write_address[2]),
                    .A3( write_address[3]),
                    .A4( write_address[4]),
                    .A5( write_address[5]),
                    .B0( read_address[0]),
                    .B1( read_address[1]),
                    .B2( read_address[2]),
                    .B3( read_address[3]),
                    .B4( read_address[4]),
                    .B5( read_address[5]),
                    .DIA0( write_data[0]),
                    .DIA1( write_data[1]),
                    .DIA2( write_data[2]),
                    .DIA3( write_data[3]),
                    .DIA4( write_data[4]),
                    .DIA5( write_data[5]),
                    .DIA6( write_data[6]),
                    .DIA7( write_data[7]),
                    .DIA8( write_data[8]),
                    .DIA9( write_data[9]),
                    .DIA10(write_data[10]),
                    .DIA11(write_data[11]),
                    .DIA12(write_data[12]),
                    .DIA13(write_data[13]),
                    .DIA14(write_data[14]),
                    .DIA15(write_data[15]),
                    .DIA16(write_data[16]),
                    .DIA17(write_data[17]),
                    .DIA18(write_data[18]),
                    .DIA19(write_data[19]),
                    .DIA20(write_data[20]),
                    .DIA21(write_data[21]),
                    .DIA22(write_data[22]),
                    .DIA23(write_data[23]),
                    .DIA24(write_data[24]),
                    .DIA25(write_data[25]),
                    .DIA26(write_data[26]),
                    .DIA27(write_data[27]),
                    .DIA28(write_data[28]),
                    .DIA29(write_data[29]),
                    .DIA30(write_data[30]),
                    .DIA31(write_data[31]),
                    .DIB0(0),
                    .DIB1(0),
                    .DIB2(0),
                    .DIB3(0),
                    .DIB4(0),
                    .DIB5(0),
                    .DIB6(0),
                    .DIB7(0),
                    .DIB8(0),
                    .DIB9(0),
                    .DIB10(0),
                    .DIB11(0),
                    .DIB12(0),
                    .DIB13(0),
                    .DIB14(0),
                    .DIB15(0),
                    .DIB16(0),
                    .DIB17(0),
                    .DIB18(0),
                    .DIB19(0),
                    .DIB20(0),
                    .DIB21(0),
                    .DIB22(0),
                    .DIB23(0),
                    .DIB24(0),
                    .DIB25(0),
                    .DIB26(0),
                    .DIB27(0),
                    .DIB28(0),
                    .DIB29(0),
                    .DIB30(0),
                    .DIB31(0),
                    .DOB0(rdata_q[0]),
                    .DOB1(rdata_q[1]),
                    .DOB2(rdata_q[2]),
                    .DOB3(rdata_q[3]),
                    .DOB4(rdata_q[4]),
                    .DOB5(rdata_q[5]),
                    .DOB6(rdata_q[6]),
                    .DOB7(rdata_q[7]),
                    .DOB8(rdata_q[8]),
                    .DOB9(rdata_q[9]),
                    .DOB10(rdata_q[10]),
                    .DOB11(rdata_q[11]),
                    .DOB12(rdata_q[12]),
                    .DOB13(rdata_q[13]),
                    .DOB14(rdata_q[14]),
                    .DOB15(rdata_q[15]),
                    .DOB16(rdata_q[16]),
                    .DOB17(rdata_q[17]),
                    .DOB18(rdata_q[18]),
                    .DOB19(rdata_q[19]),
                    .DOB20(rdata_q[20]),
                    .DOB21(rdata_q[21]),
                    .DOB22(rdata_q[22]),
                    .DOB23(rdata_q[23]),
                    .DOB24(rdata_q[24]),
                    .DOB25(rdata_q[25]),
                    .DOB26(rdata_q[26]),
                    .DOB27(rdata_q[27]),
                    .DOB28(rdata_q[28]),
                    .DOB29(rdata_q[29]),
                    .DOB30(rdata_q[30]),
                    .DOB31(rdata_q[31])
                );

reg [1:0] state1;
reg [1:0] state2;
reg [8:0] w_cnt , r_cnt;

reg [6:0] wptr_min1 , rptr_min1;
reg [6:0] wptr_r_min1 , rptr_w_min1;
always@(*) begin
    wptr_min1 = wptr ;
    if(wptr[6]) begin
        wptr_min1[5] =  ~wptr[5];
    end

    rptr_min1 = rptr ;
    if(rptr[6]) begin
        rptr_min1[5] =  ~rptr[5];
    end

    rptr_w_min1 = rptr_to_w ;
    if(rptr_to_w[6]) begin
        rptr_w_min1 [5] =  ~rptr_to_w[5];
    end

    wptr_r_min1 = wptr_to_r;
    if(wptr_to_r[6]) begin
        wptr_r_min1[5] =  ~wptr_to_r[5];
    end
end




always@(*) begin
    if( (rptr_min1[6:0] == wptr_r_min1[6:0] ) || ( wptr_r_min1[6:0] == 7'b1100000 && rptr_min1[6:0] == 0))
        fifo_clk3_flag3 = 1; // empty
    else
        fifo_clk3_flag3 = 0;
end

wire full;
assign full =  ((wptr_min1[6] != rptr_w_min1[6] ) && (wptr_min1[5:0] == rptr_w_min1[5:0] ));

always@(posedge wclk) begin
    clk2_fifo_flag3 <= full; // full
end

assign CS1 =  ~full; // when full = 1 cs1 == 0 (standby)
assign wfull = 0;
assign rempty = 0;


reg [6:0]read_temp;
always@(posedge wclk or negedge rst_n) begin // read_adrdreaa block
    if(!rst_n) begin
        read_temp <= -1;
    end
    else begin
        if(state1 == 0) begin
            if(winc == 1 && full == 0) begin
                read_temp <=  read_temp + 1;
            end
        end
    end
end

reg add_flag;
always@(*) begin
    add_flag =  (state1 == 0) && (winc == 1 && full == 0);
end
always@(posedge wclk or negedge rst_n) begin //   write_address  block;
    if(!rst_n) begin
        write_address <= -1;
    end
    else begin
        if(add_flag)
            write_address <=  write_address + 1;

    end
end

always@(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        state1 <= 0;
        WEB1 <= 0; // write

        w_cnt <= 0;
    end
    else begin
        case(state1)
            0: begin
                if(winc == 1) begin

                    if(full == 1) begin
                        state1 <= 1;
                    end
                    else begin
                        WEB1 <= 0; // write
                        write_data <= wdata;

                        w_cnt <= w_cnt + 1;
                    end
                end

                if(w_cnt == 256) begin
                    state1 <= 2;
                    w_cnt <= 0;
                end

            end
            1: begin // wait to not full
                if(full == 0) begin
                    state1 <= 0;
                end
            end
            2: begin
                if(full == 0) begin // write last data

                    state1 <= 3;
                end
            end
            3: begin
                WEB1 <= 1; // end of write
                w_cnt <= 0;
                state1 <= 0;
            end
        endcase
    end
end


always@(posedge rclk or negedge rst_n) begin // read_adrdreaa block
    if(!rst_n) begin
        read_address <= 0;
    end
    else begin
        if ( fifo_clk3_flag3 == 0)
            read_address <= read_address + 1;
        else
            read_address <= 0;

    end
end


always@(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        state2 <= 0;

        r_cnt <= 0;
    end
    else begin
        case(state2)
            0: begin
                //if(rempty == 0) begin
                if ( fifo_clk3_flag3 == 0) begin // empty
                    r_cnt <= r_cnt + 1;
                    state2 <= 1;
                end

            end
            1: begin // output data to clk3

                if(r_cnt == 256) begin
                    state2 <= 2;
                end
                else begin
                    r_cnt <= r_cnt + 1;
                end

            end
            2: begin
                state2 <= 0;
                r_cnt <= 0;
            end
        endcase
    end
end

endmodule

