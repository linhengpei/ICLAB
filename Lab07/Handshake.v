module Handshake_syn #(parameter WIDTH=32) (
           sclk,
           dclk,
           rst_n,
           sready,
           din,
           dbusy,
           sidle,
           dvalid,
           dout,

           clk1_handshake_flag1,
           clk1_handshake_flag2,
           clk1_handshake_flag3,
           clk1_handshake_flag4,

           handshake_clk2_flag1,
           handshake_clk2_flag2,
           handshake_clk2_flag3,
           handshake_clk2_flag4
       );

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output reg sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
input       clk1_handshake_flag1;  // clk1 -> handshake transmit
input       clk1_handshake_flag2;
output reg  clk1_handshake_flag3;  // handshake -> clk1 transmit
output reg  clk1_handshake_flag4;

output reg handshake_clk2_flag1;  // handshake -> clk2  transmit
output reg handshake_clk2_flag2;
input      handshake_clk2_flag3;  // clk2 -> handshake ->  transmit
input      handshake_clk2_flag4;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;
reg [2:0]state1 ,state2;

reg [31:0]data_temp;
NDFF_syn ndff1(.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn ndff2(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));
// clk1 to handshake
always@(posedge sclk or negedge rst_n) begin
    if(!rst_n) begin
        state1 <= 0;

        sidle <= 0;
        sreq <= 0;

    end
    else begin
        case(state1)
            0: begin
                if(sready == 1) begin // load data
                    data_temp <= din;
                    sidle <= 1;
                    state1 <= 1;
                end
                else begin
                    data_temp <= 0;
                    sidle <= 0;
                end
            end
            1: begin  // end load
                // sidle <= 0;
                state1 <= 2;
            end
            2: begin // start transmit
                if(sack == 0) begin
                    sreq <= 1;
                end
                else begin
                    sreq <= 0;
                    state1 <= 3;
                end
            end
            3: begin
                if(sack == 0) begin
                    state1 <= 4;
                    sidle <= 1;
                end
            end
            4: begin
                state1 <= 0;
                sidle <= 0;
            end
        endcase
    end
end

//handshake to clk2
always@(posedge dclk or negedge rst_n) begin
    if(!rst_n) begin
        state2 <= 0;

        dvalid <= 0;
        dout <= 0;
        dack <= 0 ;
    end
    else begin
        case(state2)
            0: begin  // start transmit
                if(dreq == 1) begin
                    dack <= 1;
                    state2 <= 1;
                end
            end
            1: begin
                if(dbusy == 0) begin
                    dout <= data_temp;
                    dvalid <= 1;
                end
                else begin
                    dout <= 0;
                    dvalid <= 0;
                    state2 <= 2;
                end
            end
            2: begin
                if(dreq == 0) begin
                    state2 <= 0;
                    dack <= 0;
                end
            end
        endcase
    end
end

endmodule

