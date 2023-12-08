`include "Usertype_BEV.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;
//   Coverage Part

class BEV;
    Bev_Type bev_type;
    Bev_Size bev_size;
endclass

logic  [1:0] act_change;
logic  [1:0] err_msg;
logic  [11:0] quantity;

BEV bev_info = new();

always_comb begin
    if (inf.sel_action_valid) begin
        act_change = inf.D.d_act[0];
    end
    
    if (inf.type_valid) begin
        bev_info.bev_type = inf.D.d_type[0];
    end
    
    if (inf.size_valid) begin
        bev_info.bev_size = inf.D.d_size[0];
    end
    
    if (inf. box_sup_valid) begin
        quantity = inf.D.d_ing[0];
    end
    
    if (inf.out_valid) begin
        err_msg = inf.err_msg;
    end
end

// 1. Each case of Beverage_Type should be select at least 100 times.
covergroup Spec1 @(posedge clk iff (inf.type_valid));
    option.per_instance = 1;
    option.at_least = 100;
    btype:coverpoint bev_info.bev_type{
        bins b_bev_type [] = {[ Black_Tea : Super_Pineapple_Milk_Tea ]};
    }
endgroup

// 2. Each case of Bererage_Size should be select at least 100 times.
covergroup Spec2 @(posedge clk iff (inf.size_valid));
    option.per_instance = 1;
    option.at_least = 100;
    bsize:coverpoint bev_info.bev_size{
        bins b_bev_size [] = { 0 , 1 , 3 };
    }
endgroup

/*
3.	Create a cross bin for the SPEC1 and SPEC2. Each combination should be selected at least 100 times. 
(Black Tea, Milk Tea, Extra Milk Tea, Green Tea, Green Milk Tea, Pineapple Juice, Super Pineapple Tea, Super Pineapple Tea) x (L, M, S)
*/
covergroup Spec3 @(posedge clk iff (inf.out_valid  &&  act_change == 0) );
    option.per_instance = 1;
    option.at_least = 100;
    bcross:cross   bev_info.bev_type , bev_info.bev_size;
endgroup

//4. Output signal inf.err_msg should be No_Err, No_Exp, No_Ing and Ing_OF, each at least 20 times. (Sample the value when inf.out_valid is high)
covergroup Spec4 @(posedge clk iff (inf.out_valid));
//covergroup Spec4 @(  inf.out_valid);
    option.per_instance = 1;
    option.at_least = 20;
    emsg:coverpoint err_msg{
        bins err_msg_array [] = { [ 0 : 3 ]};
    }
endgroup
//5. Create the transitions bin for the inf.D.act[0] signal from [0:2] to [0:2]. Each transition should be hit at least 200 times. (sample the value at posedge clk iff inf.sel_action_valid)
covergroup Spec5 @(posedge clk iff(inf.sel_action_valid));
    option.per_instance = 1;
    option.at_least = 200;
    trans:coverpoint act_change{
        //bins array1 [] = ([0:2]  => [0:2]);
        bins array1 [] = ( 0  => 0);
        bins array2 [] = ( 0  => 1);
        bins array3 [] = ( 0  => 2);
        bins array4 [] = ( 1  => 0);
        bins array5 [] = ( 1  => 1);
        bins array6 [] = ( 1  => 2);
        bins array7 [] = ( 2  => 0);
        bins array8 [] = ( 2  => 1);
        bins array9 [] = ( 2  => 2);
    }
endgroup


//6. Create a covergroup for material of supply action with auto_bin_max = 32, and each bin have to hit at least one time.

covergroup Spec6 @(posedge clk);
    option.per_instance = 1;
    option.at_least = 1;
    quan:coverpoint quantity{
        option.auto_bin_max = 32;
       // bins quantity_array [32] = { [ 0 : 4095 ]};
    }
endgroup


//   Create instances of Spec1, Spec2, Spec3, Spec4, Spec5, and Spec6
// Spec1_2_3 cov_inst_1_2_3 = new();

Spec1 spec1_inst = new();
Spec2 spec2_inst = new();
Spec3 spec3_inst = new();
Spec4 spec4_inst = new();
Spec5 spec5_inst = new();
Spec6 spec6_inst = new();

//    Asseration

//    1. All outputs signals (including BEV.sv and bridge.sv) should be zero after reset.
always @(negedge inf.rst_n) begin
    #1;  
    SPEC1 : assert (inf.rst_n       === 0 && inf.out_valid === 0 && inf.err_msg    === 0 && inf.complete === 0 && 
                    inf.C_addr      === 0 && inf.C_data_w  === 0 && inf.C_in_valid === 0 && inf.C_r_wb   === 0 &&   
                    inf.AR_VALID    === 0 && inf.AR_ADDR   === 0 && inf.R_READY    === 0 && inf.AW_VALID === 0 && 
                    inf.AW_ADDR     === 0 && inf.W_VALID   === 0 && inf.W_DATA     === 0 && inf.B_READY  === 0 && 
                    inf.C_out_valid === 0 && inf.C_data_r  === 0 )  
            else begin
                $display("*************************************************************************");
                $display("*                    Assertion 1 is violated                            *");
                $display("*************************************************************************");
                $fatal;
            end
end

//   2.	Latency should be less than 1000 cycles for each operation.
always@(negedge clk )begin
    if(inf.sel_action_valid === 1)begin
        SPEC2 : assert property (over_1000)
                else begin
                    $display("*************************************************************************");
                    $display("*                    Assertion 2 is violated                            *");
                    $display("*************************************************************************");
                    $fatal;
                end
    end
end
property over_1000 ; 
    @(negedge clk ) inf.sel_action_valid === 1 ##[1:1000] inf.out_valid === 1 ;
endproperty

// 3. . If action is completed (complete=1), err_msg should be 2’b0 (no_err)
SPEC3 : assert property (complete)
        else begin
            $display("*************************************************************************");
            $display("*                    Assertion 3 is violated                            *");
            $display("*************************************************************************");
            $fatal;
        end

property complete ; 
    @(negedge clk ) inf.complete === 1 |-> inf.err_msg === 0 ;
endproperty

// 4. Next input valid will be valid 1-4 cycles after previous input valid fall.
always@(negedge clk)begin
    if(inf.sel_action_valid === 1)begin
        case(inf.D.d_act[0])
        0:begin
            SPEC4_1 : assert property (make_valid)
                else begin
                    $display("*************************************************************************");
                    $display("*                    Assertion 4 is violated                            *");
                    $display("*************************************************************************");
                    $fatal;
                end
        end
        1:begin
            SPEC4_2 : assert property (supply_valid)
                else begin
                    $display("*************************************************************************");
                    $display("*                    Assertion 4 is violated                            *");
                    $display("*************************************************************************");
                    $fatal;
                end
        end
        2:begin
            SPEC4_3 : assert property (check_valid)
                else begin
                    $display("*************************************************************************");
                    $display("*                    Assertion 4 is violated                            *");
                    $display("*************************************************************************");
                    $fatal;
                end
        end
        endcase    
    end
end

property make_valid ; 
   @(negedge clk ) (inf.sel_action_valid === 1 ##[1:4] inf.type_valid === 1 ##[1:4] inf.size_valid === 1  ##[1:4] inf.date_valid === 1 ##[1:4] inf.box_no_valid === 1 );        
endproperty

property supply_valid ; 
   @(negedge clk ) (inf.sel_action_valid === 1 ##[1:4] inf.date_valid === 1 ##[1:4] inf.box_no_valid === 1 ##[1:4] inf.box_sup_valid === 1  ##[1:4] inf.box_sup_valid === 1 ##[1:4] inf.box_sup_valid === 1 ##[1:4] inf.box_sup_valid === 1 );        
endproperty

property check_valid ; 
   @(negedge clk ) (inf.sel_action_valid === 1 ##[1:4] inf.date_valid === 1 ##[1:4] inf.box_no_valid === 1 );        
endproperty

// 5. All input valid signals won't overlap with each other.
logic[5:0] Valid ;
always@(negedge clk)begin
    Valid[0] = inf.sel_action_valid ;
    Valid[1] = inf.type_valid;
    Valid[2] = inf.size_valid;
    Valid[3] = inf.date_valid;
    Valid[4] = inf.box_no_valid;
    Valid[5] = inf.box_sup_valid; 
    if(Valid[0] || Valid[1] || Valid[2] || Valid[3] || Valid[4] || Valid[5])begin
        SPEC5 : assert ($onehot(Valid))
                else begin
                    $display("*************************************************************************");
                    $display("*                    Assertion 5 is violated                            *");
                    $display("*************************************************************************");
                    $fatal;
                end
    end        
end

//  6. Out_valid can only be high for exactly one cycle.
SPEC6 : assert property (overlap)
        else begin
            $display("*************************************************************************");
            $display("*                    Assertion 6 is violated                            *");
            $display("*************************************************************************");
            $fatal;
        end

property overlap ; 
    @(negedge clk ) inf.out_valid === 1 |=> inf.out_valid === 0 ;
endproperty

//    7. Next operation will be valid 1-4 cycles after out_valid fall.
always@(*)begin
    if(inf.out_valid === 1)begin
        SPEC7 : assert property (next_oper)
                else begin
                    $display("*************************************************************************");
                    $display("*                    Assertion 7 is violated                            *");
                    $display("*************************************************************************");
                    $fatal;
                end
    end
end
property next_oper ; 
    @(negedge clk )  inf.out_valid === 1  ##[2:5] inf.sel_action_valid === 1 ;
endproperty

logic [3:0] Month ;
logic [4:0] Day   ;
logic wrong;
//   8. The input date from pattern should adhere to the real calendar. (ex: 2/29, 3/0, 4/31, 13/1 are illegal cases)
always@(negedge clk )begin
    if(inf.date_valid === 1)begin
        { Month , Day } = inf.D.d_date[0] ;
        //$display("%d %d", Month , Day );

        wrong = 1;
        case(Month)
            2:begin
                if( Day < 1 || Day > 28)
                    wrong = 0;
            end
            1,3,5,7,8,10,12:begin
                if( Day < 1 || Day > 31)       
                    wrong = 0;
            end
            4,6,9,11:begin
                if( Day < 1 || Day > 30)       
                    wrong = 0;
            end
            default : wrong = 0; 
        endcase
        //$display("%d ", wrong );
        SPEC8 : assert  (wrong)
                else begin
                    $display("*************************************************************************");
                    $display("*                    Assertion 8 is violated                            *");
                    $display("*************************************************************************");
                    $fatal;
                end
        end       
end

//   9. C_in_valid can only be high for one cycle and can't be pulled high again before C_out_valid
always@(*)begin
    if(inf.C_in_valid === 1)begin
        SPEC9 : assert property (one)
                else begin
                    $display("*************************************************************************");
                    $display("*                    Assertion 9 is violated                            *");
                    $display("*************************************************************************");
                    $fatal;
                end
    end
end

property one; 
    @(negedge clk )  inf.C_in_valid === 1  ##1  inf.C_in_valid === 0 ;
endproperty

endmodule
