//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT_TOP(
           // Input signals
           clk,
           rst_n,
           in_valid,
           in_weight,
           out_mode,
           // Output signals
           out_valid,
           out_code
       );
input clk, rst_n, in_valid, out_mode;
input [2:0] in_weight;

output reg out_valid, out_code;

reg  [31 : 0]sort_c_in ;
reg  [39 : 0]sort_w    ;
wire [31 : 0]sort_c_out ;

SORT_IP #(.IP_WIDTH(8)) SORT(.IN_character(sort_c_in), .IN_weight(sort_w), .OUT_character(sort_c_out));

reg [3:0]state;
reg [2:0] counter ;
reg mode;

parameter Output_I = 6,
          Output_L = 7,
          Output_O = 8,
          Output_V = 9,
          Output_E = 10,
          Output_C = 11,
          Output_A = 13,
          Output_B = 14;

reg [2:0] test_number[7:0] ; // 3 bits * 8

reg [4:0] group_weight[7:0] ; // 5 bits * 8
reg [7:0] group_member[7:0] ; // 8 bits * 8
reg [3:0] group_number      ;
reg [6:0] HC [7:0]     ; // 7 bits * 8
reg [2:0] HC_long[7:0] ; // 3 bits * 8
reg [6:0]check ;

reg [3:0]last ;
reg [3:0]second_last;

reg [3:0]weight_last ;
reg [3:0]weight_second_last;

always@(*) begin
    case(group_number)
        default: begin
            second_last =  test_number[( 8 - group_number) ];
            last        =  test_number[( 7 - group_number) ];
            weight_second_last =  ( 8 - group_number) ;
            weight_last =   ( 7 - group_number) ;
        end
    endcase
end


wire [4:0] new_weight ;
assign new_weight = group_weight[ weight_second_last] + group_weight[ weight_last];


integer  i;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0 ;
        out_code  <= 0 ;

        state <= 0;
        counter <= 0;
    end
    else begin
        case(state)
            0: begin
                group_number <= 7;

                for( i = 7 ; i >= 0 ; i = i - 1) begin
                    HC[i] <= 1;
                    HC_long[i] <= 0;

                    group_weight[i] <= 0; //  min
                end
                check <= 7'b1111111;

                group_member[7] <= 8'b10000000;
                group_member[6] <= 8'b01000000;
                group_member[5] <= 8'b00100000;
                group_member[4] <= 8'b00010000;
                group_member[3] <= 8'b00001000;
                group_member[2] <= 8'b00000100;
                group_member[1] <= 8'b00000010;
                group_member[0] <= 8'b00000001;

                if(in_valid) begin
                    mode <= out_mode;

                    group_weight[7] <= in_weight;
                    test_number[7] <= 7;

                    counter <= 6;
                    state <= state + 1;
                end
            end

            1: begin

                if(in_weight > group_weight [4] || check[4] ) begin
                    if(in_weight > group_weight [6] || check[6]) begin
                        if(in_weight > group_weight [7] ) begin
                            group_weight[7] <= in_weight;
                            test_number[7] <= counter ;
                            for(i = 7 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                                check[i - 1] <= check[i] ;
                            end
                        end
                        else begin
                            group_weight[6] <= in_weight;
                            test_number[6] <= counter ;
                            check[6] <= 0;
                            for(i = 6 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                                check[i - 1] <= check[i] ;
                            end
                        end
                    end
                    else begin
                        if(in_weight > group_weight [5] || check[5]) begin
                            group_weight[5] <= in_weight;
                            test_number[5] <= counter;
                            check[5] <= 0;
                            for(i = 5 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                                check[i - 1] <= check[i] ;
                            end
                        end
                        else begin
                            group_weight[4] <= in_weight;
                            test_number[4] <= counter;
                            check[4] <= 0;
                            for(i = 4 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                                check[i - 1] <= check[i] ;
                            end
                        end
                    end
                end
                else begin
                    if(in_weight > group_weight [2] || check[2]) begin
                        if(in_weight > group_weight [3] || check[3]) begin
                            group_weight[3] <= in_weight;
                            test_number[3] <= counter;
                            check[3] <= 0;
                            for(i = 3 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                                check[i - 1] <= check[i] ;
                            end
                        end
                        else begin
                            group_weight[2] <= in_weight;
                            test_number[2] <= counter;
                            check[2] <= 0;
                            for(i = 2 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                                check[i - 1] <= check[i] ;
                            end
                        end
                    end
                    else begin
                        if(in_weight > group_weight [1] || check[1]) begin
                            group_weight[1] <= in_weight;
                            test_number[1] <= counter;
                            check[1] <= 0;
                            for(i = 1 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                                check[i - 1] <= check[i] ;
                            end
                        end
                        else begin
                            group_weight[0] <= in_weight;
                            test_number[0] <= counter;
                            check[0] <= 0;
                        end
                    end
                end

                if(counter == 0) begin
                    state <= state + 1;
                end
                else
                    counter <= counter - 1;
            end


            2: begin  //combine
                for(i = 0 ; i < 8; i = i + 1) begin
                    if(group_member[last][i]) begin  //code 1
                        HC[i] <= {HC[i][6:0],1'b1 };
                        HC_long[i] <= HC_long[i] + 1;
                    end

                    if(group_member[second_last][i]) begin  //code 0
                        HC[i] <= {HC[i][6:0],1'b0 };
                        HC_long[i] <= HC_long[i] + 1;
                    end
                end
                group_number <= group_number - 1;
                // group_weight[weight_second_last ] <=  new_weight ;
                group_member[ second_last ] <= group_member[ last] | group_member[ second_last];
                // group_weight[weight_last] <= 0 ;
                // group_member[ last] <= 0;
                // can remove

                if(new_weight > group_weight [4]) begin
                    if(new_weight > group_weight [6]) begin
                        if(new_weight > group_weight [7]) begin
                            group_weight[7] <= new_weight;
                            test_number[7] <= second_last ;
                            for(i = 7 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                            end
                        end
                        else begin
                            group_weight[6] <= new_weight;
                            test_number[6] <= second_last ;
                            for(i = 6 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                            end
                        end
                    end
                    else begin
                        if(new_weight > group_weight [5]) begin
                            group_weight[5] <= new_weight;
                            test_number[5] <= second_last;
                            for(i = 5 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                            end
                        end
                        else begin
                            group_weight[4] <= new_weight;
                            test_number[4] <= second_last;

                            for(i = 4 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                            end

                        end
                    end
                end
                else begin
                    if(new_weight > group_weight [2]) begin
                        if(new_weight > group_weight [3]) begin
                            group_weight[3] <= new_weight;
                            test_number[3] <= second_last;
                            for(i = 3 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                            end
                        end
                        else begin
                            group_weight[2] <= new_weight;
                            test_number[2] <= second_last;
                            for(i = 2 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                            end
                        end
                    end
                    else begin
                        if(new_weight > group_weight [1]) begin
                            group_weight[1] <= new_weight;
                            test_number[1] <= second_last;
                            for(i = 1 ; i > 0 ; i = i - 1) begin
                                group_weight[i - 1] <= group_weight[i];
                                test_number[i - 1] <= test_number[i];
                            end
                        end
                        else begin
                            group_weight[0] <= new_weight;
                            test_number[0] <= second_last;
                        end
                    end
                end


                if(group_number == 1)
                    state <=  Output_I;
            end
            Output_I: begin // start output
                out_valid  <= 1 ;
                out_code <= HC[3][0];
                HC[3] <= ( HC[3] >> 1);

                if(HC_long[3] == 1) begin
                    if(mode == 0) //ILOVE
                        state <=  state + 1;
                    else // ICLAB
                        state <= Output_C;
                end
                else begin
                    HC_long[3] <= HC_long[3] - 1;
                end
            end
            Output_L: begin // 7
                out_code <= HC[2][0];
                HC[2] <= ( HC[2] >> 1);

                if(HC_long[2] == 1) begin
                    if(mode == 0) //ILOVE
                        state <= state + 1;
                    else // ICLAB
                        state <= Output_A;
                end
                else
                    HC_long[2] <= HC_long[2] - 1;
            end
            Output_O: begin// 8
                out_code <= HC[1][0];
                HC[1] <= ( HC[1] >> 1);

                if(HC_long[1] == 1)
                    state <= state + 1;
                else
                    HC_long[1] <= HC_long[1] - 1;
            end
            Output_V: begin // 9
                out_code <= HC[0][0];
                HC[0] <= ( HC[0] >> 1);

                if(HC_long[0] == 1)
                    state <= state + 1;
                else
                    HC_long[0] <= HC_long[0] - 1;
            end
            Output_E: begin // 10
                out_code <= HC[4][0];
                HC[4] <= ( HC[4] >> 1);

                if(HC_long[4] == 1)
                    state <= 15;
                else
                    HC_long[4] <= HC_long[4] - 1;
            end

            Output_C: begin // 11
                out_code <= HC[5][0];
                HC[5] <= ( HC[5] >> 1);

                if(HC_long[5] == 1)
                    state <= Output_L;
                else
                    HC_long[5] <= HC_long[5] - 1;
            end
            Output_A: begin // 12
                out_code <= HC[7][0];
                HC[7] <= ( HC[7] >> 1);

                if(HC_long[7] == 1)
                    state <= state + 1;
                else
                    HC_long[7] <= HC_long[7] - 1;
            end
            Output_B: begin // 13
                out_code <= HC[6][0];
                HC[6] <= ( HC[6] >> 1);

                if(HC_long[6] == 1)
                    state <= state + 1;
                else
                    HC_long[6] <= HC_long[6] - 1;
            end
            15: begin
                out_valid <= 0;
                out_code  <= 0;
                state <= 0;
            end
        endcase
    end

end
endmodule //  34325.928085 4.5
