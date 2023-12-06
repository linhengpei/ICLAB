module BEV(input clk, INF.BEV_inf inf);
import usertype::*;
// This file contains the definition of several state machines used in the BEV (Beverage) System RTL design.
// The state machines are defined using SystemVerilog enumerated types.
// The state machines are:
// - state_t: used to represent the overall state of the BEV system
//
// Each enumerated type defines a set of named states that the corresponding process can be in.
typedef enum logic [2:0]{
            IDLE,
            MAKE_DRINK,
            SUPPLY,
            CHECK_DATE,
            WAIT_BUSY,
            WAIT_OUT
        } state_t;

state_t c_state;

logic [7:0] black , green , milk, pineapple;
/*
240 11,1100,0000  /4 = 240
180 10,1101,0000     = 180
480  1,1110,0000     = 120
240    1111,0000     
*/
logic [1:0] supply_cnt;
always_comb begin
    black = 0;
    green = 0;
    milk = 0;
    pineapple = 0;
    case(inf.C_data_w[13:11])
        Black_Tea : begin
            case(inf.C_data_w[10:9])
                L : black = 240 ;
                M : black = 180 ;
                S : black = 120 ;
            endcase              
        end
        Milk_Tea  : begin
            case(inf.C_data_w[10:9])
                L:begin
                    black = 180 ;
                    milk = 60;
                end
                M : begin
                    black = 135 ;
                    milk = 45 ;
                end
                S : begin
                    black = 90 ;
                    milk = 30 ;
                end
            endcase 
            // black = 720;
            //  milk = 240;
        end
        Extra_Milk_Tea : begin
            case(inf.C_data_w[10:9])
                L:begin
                    black = 120 ;
                    milk = 120;
                end
                M : begin
                    black = 90 ;
                    milk = 90 ;
                end
                S : begin
                    black = 60 ;
                    milk = 60 ;
                end
            endcase 
            //black = 480;
            //milk  = 480;
        end
        Green_Tea :begin
            case(inf.C_data_w[10:9])
                L : green = 240 ;
                M : green = 180 ;
                S : green = 120 ;
            endcase 
            //green = 960;
        end    
        Green_Milk_Tea : begin
            case(inf.C_data_w[10:9])
                L:begin
                    green = 120 ;
                    milk = 120;
                end
                M : begin
                    green = 90 ;
                    milk = 90 ;
                end
                S : begin
                    green = 60 ;
                    milk = 60 ;
                end
            endcase 
            //green = 480;
            //milk  = 480;
        end
        Pineapple_Juice : begin
            case(inf.C_data_w[10:9])
                L : pineapple = 240 ;
                M : pineapple = 180 ;
                S : pineapple = 120 ;
            endcase 
            //pineapple = 960;
        end
        Super_Pineapple_Tea : begin
            case(inf.C_data_w[10:9])
                L:begin
                    black = 120 ;
                    pineapple = 120;
                end
                M : begin
                    black = 90 ;
                    pineapple = 90 ;
                end
                S : begin
                    black = 60 ;
                    pineapple = 60 ;
                end
            endcase 
            // black = 480;
            // pineapple  = 480;
        end
        Super_Pineapple_Milk_Tea : begin
            case(inf.C_data_w[10:9])
                L:begin
                    black = 120 ;
                    milk = 60 ;
                    pineapple = 60 ;
                end
                M : begin
                    black = 90 ;
                    milk = 45 ;
                    pineapple = 45 ;
                end
                S : begin
                    black = 60 ;
                    milk = 30 ;
                    pineapple = 30 ;
                end
            endcase 
            // black = 480;
            // milk  = 240;
            // pineapple = 240;
        end
    endcase
end

assign inf.C_r_wb = 0 ;
/*
   output out_valid, err_msg, complete,
            C_addr, C_data_w, C_in_valid, C_r_wb
*/
always_ff @( posedge clk  or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        c_state <= IDLE;

        inf.out_valid <= 0;
        inf.complete <= 0;
        inf.err_msg <= 0;

        inf.C_addr <= 0;
        inf.C_in_valid  <= 0;
        inf.C_data_w <= 0;
        supply_cnt <= 0;
    end
    else begin
        case(c_state)
            IDLE: begin
                inf.out_valid <= 0;
                inf.complete <= 0;
                inf.err_msg <= 0;
                if (inf.sel_action_valid) begin
                    inf.C_data_w[63:62] <= inf.D.d_act[0];
                    case(inf.D.d_act[0])
                        Make_drink:
                            c_state <= MAKE_DRINK;
                        Supply:
                            c_state <= SUPPLY;
                        Check_Valid_Date:
                            c_state <= CHECK_DATE;
                    endcase
                end
            end
            MAKE_DRINK: begin
                if(inf.type_valid)
                    inf.C_data_w[13:11] <= inf.D.d_type[0];
                if(inf.size_valid)
                    inf.C_data_w[10: 9] <= inf.D.d_size[0];
                if(inf.date_valid)
                    inf.C_data_w[ 8: 0] <= inf.D.d_date[0];
                if(inf.box_no_valid) begin
                    inf.C_addr  <= inf.D.d_box_no[0];
                    c_state <=  WAIT_BUSY;
                end                

                inf.C_data_w[61:52] <= black;
                inf.C_data_w[49:40] <= green;
                inf.C_data_w[37:28] <= milk;
                inf.C_data_w[25:16] <= pineapple;
            end
            SUPPLY : begin
                if(inf.date_valid)
                    inf.C_data_w[ 8: 0] <= inf.D.d_date[0];
                if(inf.box_no_valid)
                    inf.C_addr  <= inf.D.d_box_no[0];
                if(inf.box_sup_valid) begin
                    inf.C_data_w[ 25: 14] <= inf.D.d_ing[0];
                    inf.C_data_w[ 61: 26] <= inf.C_data_w[ 49: 14]; 

                    supply_cnt <= supply_cnt + 1;
                    if(supply_cnt == 3)
                        c_state <= WAIT_BUSY;
                end

            end
            CHECK_DATE : begin
                if(inf.date_valid)
                    inf.C_data_w[ 8: 0] <= inf.D.d_date[0];
                if(inf.box_no_valid) begin
                    inf.C_addr  <= inf.D.d_box_no[0];
                    c_state <=  WAIT_BUSY;
                end

            end
            WAIT_BUSY: begin
                if(!inf.C_data_r[2]) begin
                    inf.C_in_valid  <= 1;
                    c_state <=  WAIT_OUT;
                end
            end
            WAIT_OUT : begin
                inf.C_in_valid  <= 0;
                if(inf.C_out_valid) begin
                    inf.out_valid <= 1;
                    if(inf.C_data_r[1:0] == 0)
                        inf.complete <= (inf.C_data_r[1:0] == 0);
                    else
                        inf.complete <= 0;
                    inf.err_msg <= inf.C_data_r[1:0];
                    c_state <=  IDLE;
                end
            end
        endcase
    end
end
endmodule // 8905  2.4
          // 9199  2.3 
          // 9236  2.2 
